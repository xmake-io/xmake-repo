package("mmkv")
    set_homepage("https://github.com/Tencent/MMKV")
    set_description("An efficient, small mobile key-value storage framework developed by WeChat. Works on Android, iOS, macOS, Windows, POSIX, and OHOS.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/Tencent/MMKV/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Tencent/MMKV.git")

    add_versions("v2.3.0", "99ee71b937cc4c8fe7600babdf4b452e34b36d3899f7c9154ad464b9aab21a5d")

    add_links("mmkv", "core")
    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation")
    elseif is_plat("android") then
        add_syslinks("log")
    end

    add_deps("cmake")
    add_deps("zlib")

    on_check("android", function (package)
        local ndk = package:toolchain("ndk"):config("ndkver")
        assert(ndk and tonumber(ndk) > 22, "package(mmkv) require ndk version > 22")
    end)

    on_install("!mingw and !android|armeabi-v7a", function (package)
        io.replace("Core/CMakeLists.txt", "STATIC", "", {plain = true})
        io.replace("Core/CMakeLists.txt", "POSITION_INDEPENDENT_CODE ON", "", {plain = true})
        io.replace("Core/CMakeLists.txt",
            "target_link_libraries(core ${zlib})",
            "find_package(ZLIB)\ntarget_link_libraries(core PUBLIC ZLIB::ZLIB)", {plain = true})

        io.replace("POSIX/src/CMakeLists.txt", "SHARED", "", {plain = true})
        if not package:is_plat("linux", "bsd") then
            io.replace("POSIX/src/CMakeLists.txt", "pthread", "", {plain = true})
        end

        local file = io.open("POSIX/src/CMakeLists.txt", "a")
        file:write(format([[
            include(GNUInstallDirs)
            install(TARGETS core)
            install(TARGETS mmkv)
        ]]))
        file:close()

        io.replace("Core/crc32/Checksum.h", "#include <vector>", "#include <vector>\n#include <cstdint>", {plain = true})
        if package:config("shared") and package:is_plat("windows") then
            io.replace("Core/MMKVPredef.h", "#define MMKV_EXPORT", "#define MMKV_EXPORT __declspec(dllexport)", {plain = true})
        end

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        local old = os.cd("POSIX/src")
        import("package.tools.cmake").install(package, configs)
        os.cd(old)

        if package:config("shared") and package:is_plat("windows") then
            io.replace("Core/MMKVPredef.h", "#define MMKV_EXPORT __declspec(dllexport)", "#define MMKV_EXPORT __declspec(dllimport)", {plain = true})
        end

        os.vcp("Core/*.h", package:installdir("include/MMKV"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto mmkv = MMKV_NAMESPACE_PREFIX::MMKV::defaultMMKV();
            }
        ]]}, {configs = {languages = "c++20"}, includes = "MMKV/MMKV.h"}))
    end)
