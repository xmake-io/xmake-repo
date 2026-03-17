package("lz4")
    set_homepage("https://www.lz4.org/")
    set_description("LZ4 - Extremely fast compression")
    set_license("BSD-2-Clause")

    set_urls("https://github.com/lz4/lz4/archive/refs/tags/$(version).tar.gz",
             "https://github.com/lz4/lz4.git")

    add_versions("v1.10.0", "537512904744b35e232912055ccf8ec66d768639ff3abe5788d90d792ec5f48b")
    add_versions("v1.9.4", "0b0e3aa07c8c063ddf40b082bdf7e37a1562bda40a0ff5272957f3e987e0e54b")
    add_versions("v1.9.3", "030644df4611007ff7dc962d981f390361e6c97a34e5cbc393ddfbe019ffe2c1")

    add_configs("cmake", {description = "Use cmake build system", default = true, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("macosx") then
        add_extsources("brew::lz4")
    elseif is_plat("linux") then
        add_extsources("pacman::lz4", "apt::liblz4-dev")
    end

    on_load(function (package)
        if package:config("cmake") then
            package:add("deps", "cmake")
        end

        if package:config("shared") and package:is_plat("windows") then
            package:add("defines", "LZ4_DLL_IMPORT")
        end
    end)

    on_install(function (package)
        if package:config("cmake") then
            if package:version() and package:version():le("1.10.0") then
                io.writefile("build/cmake/lz4Config.cmake.in", [[@PACKAGE_INIT@
include( "${CMAKE_CURRENT_LIST_DIR}/lz4Targets.cmake" )
if(NOT TARGET lz4::lz4)
    add_library(lz4::lz4 INTERFACE IMPORTED)
    if("@BUILD_SHARED_LIBS@")
        set_target_properties(lz4::lz4 PROPERTIES INTERFACE_LINK_LIBRARIES LZ4::lz4_shared)
    else()
        set_target_properties(lz4::lz4 PROPERTIES INTERFACE_LINK_LIBRARIES LZ4::lz4_static)
    endif()
endif()]])
            end

            local configs = {}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (not package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DLZ4_BUILD_CLI=" .. (package:config("tools") and "ON" or "OFF"))
            table.insert(configs, "-DLZ4_BUILD_LEGACY_LZ4C=" .. (package:config("tools") and "ON" or "OFF"))

            os.cd("build/cmake")
            import("package.tools.cmake").install(package, configs)
        else
            io.writefile("xmake.lua", ([[
                set_version("%s")
                option("tools", {default = false})
                add_rules("mode.debug", "mode.release", "utils.install.cmake_importfiles")
                target("lz4")
                    set_kind("$(kind)")
                    add_rules("utils.install.pkgconfig_importfiles", {filename = "liblz4.pc"})
                    add_files("lib/*.c")
                    add_headerfiles("lib/lz4.h", "lib/lz4hc.h", "lib/lz4frame.h", "lib/lz4file.h")
                    add_defines("XXH_NAMESPACE=LZ4_", {public = true})
                    if is_kind("shared") and is_plat("windows") then
                        add_defines("LZ4_DLL_EXPORT")
                        add_defines("LZ4_DLL_IMPORT", {interface = true})
                    end
                    if is_kind("static") then
                        add_defines("LZ4_HC_STATIC_LINKING_ONLY", "LZ4_STATIC_LINKING_ONLY")
                    end
                if has_config("tools") then
                    target("lz4cli")
                        set_basename("lz4")
                        set_kind("binary")
                        add_files("lib/*.c", "programs/*.c")
                        add_includedirs("lib")
                    target("lz4c")
                        set_kind("binary")
                        add_files("lib/*.c", "programs/*.c")
                        add_includedirs("lib")
                        add_defines("ENABLE_LZ4C_LEGACY_OPTIONS")
                end
            ]]):format(package:version_str()))
            import("package.tools.xmake").install(package, {tools = package:config("tools")})
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("LZ4_compress_default", {includes = {"lz4.h"}}))
        if package.check_importfiles then
            package:check_importfiles("cmake::lz4", {configs = {link_libraries = "lz4::lz4"}})
        end
    end)
