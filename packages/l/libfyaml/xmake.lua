package("libfyaml")
    set_homepage("https://github.com/pantoniou/libfyaml")
    set_description("Fully feature complete YAML parser and emitter, supporting the latest YAML spec and passing the full YAML testsuite.")
    set_license("MIT")

    add_urls("https://github.com/pantoniou/libfyaml/archive/refs/tags/$(version).tar.gz",
             "https://github.com/pantoniou/libfyaml.git")

    add_versions("v0.9.2", "979be4f6ba463c6d1a5b0d25c780486ae09c78477228e0af9368690e90a95698")
    add_versions("v0.9", "927306fc85c7566904751766d36178650766b34e59ce56882eaa5b60f791668c")

    add_deps("cmake")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) > 21, "package(libfyaml) require ndk api level > 21")
        end)
    end

    on_install("linux", "macosx", "android", "iphoneos", "cross", function (package)
        io.replace("CMakeLists.txt", "-fPIC", "", {plain = true})

        local configs = {"-DBUILD_TESTING=OFF", "-DENABLE_LIBCLANG=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("fy_library_version", {includes = "libfyaml.h"}))
    end)
