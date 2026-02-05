package("mmkv")
    set_homepage("https://github.com/Tencent/MMKV")
    set_description("An efficient, small mobile key-value storage framework developed by WeChat. Works on Android, iOS, macOS, Windows, POSIX, and OHOS.")
    set_license("BSD 3-Clause")

    add_urls("https://github.com/Tencent/MMKV/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Tencent/MMKV.git")

    add_versions("v2.3.0", "99ee71b937cc4c8fe7600babdf4b452e34b36d3899f7c9154ad464b9aab21a5d")

    add_versions("v1.3.16", "fc65c5897b6482fd28d1c957abea49fe0f7cecade61129fd98ed0f2d19188677")

    add_links("mmkv", "core")

    add_deps("cmake")
    add_deps("zlib")

    on_install(function (package)
        io.replace("Core/CMakeLists.txt", "STATIC", "", {plain = true})
        io.replace("Core/CMakeLists.txt", "POSITION_INDEPENDENT_CODE ON", "", {plain = true})
        io.replace("Core/CMakeLists.txt",
            "target_link_libraries(core ${zlib})",
            "find_package(ZLIB)\ntarget_link_libraries(core PUBLIC ZLIB::ZLIB)", {plain = true})

        io.replace("POSIX/src/CMakeLists.txt", "SHARED", "", {plain = true})
        local file = io.open("POSIX/src/CMakeLists.txt", "a")
        file:write(format([[
            include(GNUInstallDirs)
            install(TARGETS core)
            install(TARGETS mmkv)
        ]]))
        file:close()

        os.vcp("Core/*.h", package:installdir("include/MMKV"))

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        os.cd("POSIX/src")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto mmkv = MMKV::defaultMMKV();
            }
        ]]}, {configs = {languages = "c++20"}, includes = "MMKV/MMKV.h"}))
    end)
