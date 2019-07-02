package("protobuf-c")

    set_homepage("https://github.com/protobuf-c/protobuf-c")
    set_description("Google's data interchange format for c")

    add_urls("https://github.com/protobuf-c/protobuf-c/releases/download/v$(version)/protobuf-c-$(version).tar.gz")
    add_versions("1.3.1", "51472d3a191d6d7b425e32b612e477c06f73fe23e07f6a6a839b11808e9d2267")

    -- fix "error: no type named 'Reflection' in 'google::protobuf::Message'"
    -- see https://github.com/protobuf-c/protobuf-c/pull/342
    -- and https://github.com/protobuf-c/protobuf-c/issues/356
    add_patches("1.3.1", "https://github.com/protobuf-c/protobuf-c/pull/342.patch", "050306bae86af55f90606613d3c362c3c93af779aa6be3e639c6a1df3c228c87")

    add_deps("protobuf-cpp")
    if is_plat("windows") then
        add_deps("cmake")
    end

    add_links("protobuf-c")

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)
 
    on_install("windows", function (package)
        os.cd("build-cmake")
        import("package.tools.cmake").install(package, {"-Dprotobuf_BUILD_PROTOC_BINARIES=ON"})
        os.cp("build_*/Release/protoc-gen-c.exe", path.join(package:installdir("bin"), "protoc-c.exe"))
    end)

    on_install("linux", "macosx", function (package)
        import("package.tools.autoconf").install(package, {"--enable-shared=no"})
    end)

    on_test(function (package)
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
