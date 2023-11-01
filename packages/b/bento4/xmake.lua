package("bento4")
    set_homepage("http://www.bento4.com")
    set_description("Full-featured MP4 format, MPEG DASH, HLS, CMAF SDK and tools")

    add_urls("https://github.com/axiomatic-systems/Bento4.git")
    add_versions("2023.08.08", "2e2dc016274764b8eb511a3503aa37e7334be6bf")

    add_deps("cmake")

    on_install(function (package)
        if package:is_plat("android") then
            import("core.tool.toolchain")

            local ndk = toolchain.load("ndk", {plat = package:plat(), arch = package:arch()})
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) > 21, "package(bento4): need ndk api level >= 21 for android")
        end

        local configs = {"-DBUILD_APPS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <bento4/Ap4.h>
            void test() {
                AP4_Result x = AP4::Initialize();
            }
        ]]}))
    end)
