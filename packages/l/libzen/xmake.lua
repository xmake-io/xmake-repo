package("libzen")
    set_homepage("https://mediaarea.net")
    set_description("Small C++ derivate classes to have an easier life")
    set_license("zlib")

    add_urls("https://github.com/MediaArea/ZenLib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/MediaArea/ZenLib.git")

    add_versions("v0.4.41", "45d5173fa0278f5264daa6836ae297aa303984482227d00b35c4f03929494c8f")

    add_configs("unicode", {description = "Enable unicode support", default = true, type = "boolean"})
    add_configs("large_files", {description = "Enable large files support", default = true, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "m")
    end

    add_deps("cmake")

    if on_check then
        on_check("android", function (package)
            if package:is_arch("armeabi-v7a") then
                local ndk = package:toolchain("ndk")
                local ndk_sdkver = ndk:config("ndk_sdkver")
                assert(ndk_sdkver and tonumber(ndk_sdkver) >= 24, "package(libzen/armeabi-v7a): need ndk api level >= 24 for android")
            end
        end)
    end

    on_install(function (package)
        local configs = {}
        local shared = package:config("shared")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (shared and "ON" or "OFF"))
        if package:is_plat("windows") and shared then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        table.insert(configs, "-DENABLE_UNICODE=" .. (package:config("unicode") and "ON" or "OFF"))
        table.insert(configs, "-DLARGE_FILES=" .. (package:config("large_files") and "ON" or "OFF"))

        os.cd("Project/CMake")
        io.replace("CMakeLists.txt", "set(BUILD_SHARED_LIBS OFF)", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                ZenLib::LittleEndian2int8s("");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "ZenLib/Utils.h"}))
    end)
