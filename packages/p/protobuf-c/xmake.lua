package("protobuf-c")

    set_homepage("https://github.com/protobuf-c/protobuf-c")
    set_description("Google's data interchange format for c")

    add_urls("https://github.com/protobuf-c/protobuf-c/releases/download/v$(version)/protobuf-c-$(version).tar.gz")
    add_versions("1.3.1", "51472d3a191d6d7b425e32b612e477c06f73fe23e07f6a6a839b11808e9d2267")

    -- fix "error: no type named 'Reflection' in 'google::protobuf::Message'"
    -- see https://github.com/protobuf-c/protobuf-c/pull/342
    -- and https://github.com/protobuf-c/protobuf-c/issues/356
    add_patches("1.3.1", path.join(os.scriptdir(), "patches", "1.3.1", "342.patch"), "ab78f9eeff2840cacf5b6b143d284e50e43166ec2cbfa78cd47fd8db1e387c6d")

    add_deps("protobuf-cpp")
    if is_plat("windows") then
        add_deps("cmake")
    end

    add_links("protobuf-c")
    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("windows", function (package)
        -- fix run `protoc-c.exe` failed
        io.replace("protoc-c/main.cc", "invocation_basename == legacy_name", "1")
        os.cd("build-cmake")
        local cflags
        local shflags
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=ON")
            cflags = {"-DPROTOBUF_C_USE_SHARED_LIB", "-DPROTOBUF_C_EXPORT"}
            shflags = "/export:protobuf_c_empty_string"
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
        end
        if package:config("vs_runtime"):startswith("MT") then
            table.insert(configs, "-DMSVC_STATIC_BUILD=ON")
        else
            table.insert(configs, "-DMSVC_STATIC_BUILD=OFF")
        end
        import("package.tools.cmake").install(package, configs, {cflags = cflags, shflags = shflags})
        os.cp("build_*/Release/protoc-gen-c.exe", path.join(package:installdir("bin"), "protoc-c.exe"))
    end)

    on_install("linux", "macosx", function (package)
        local configs = {}
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
            table.insert(configs, "--enable-static=no")
        else
            table.insert(configs, "--enable-static=yes")
            table.insert(configs, "--enable-shared=no")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        if package:is_cross() then
            return
        end
        io.writefile("test.proto", [[
            syntax = "proto3";
            package test;
            message TestCase {
                string name = 4;
            }
            message Test {
                repeated TestCase case = 1;
            }
        ]])
        os.vrun("protoc-c test.proto -I. --c_out=.")
        assert(package:check_csnippets({test = io.readfile("test.pb-c.c")}, {configs = {includedirs = {".", package:installdir("include")}}}))
    end)
