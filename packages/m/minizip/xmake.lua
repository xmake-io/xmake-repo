package("minizip")
    set_homepage("https://www.zlib.net/")
    set_description("Mini zip and unzip based on zlib")
    set_license("zlib")

    add_urls("https://github.com/madler/zlib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/madler/zlib.git")

    add_versions("v1.3.1", "17e88863f3600672ab49182f217281b6fc4d3c762bde361935e436a95214d05c")
    add_versions("v1.2.10", "42cd7b2bdaf1c4570e0877e61f2fdc0bce8019492431d054d3d86925e5058dc5")
    add_versions("v1.2.11", "629380c90a77b964d896ed37163f5c3a34f6e6d897311f1df2a7016355c45eff")
    add_versions("v1.2.12", "d8688496ea40fb61787500e863cc63c9afcbc524468cedeb478068924eb54932")
    add_versions("v1.2.13", "1525952a0a567581792613a9723333d7f8cc20b87a81f920fb8bc7e3f2251428")

    add_configs("cmake", {description = "Use cmake build system", default = true, type = "boolean"})
    add_configs("bzip2", {description = "Build minizip withj bzip2 support", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("zlib")

    add_includedirs("include", "include/minizip")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) >= 23, "package(minizip) require ndk api level >= 23")
        end)
    end

    on_load(function (package)
        if package:config("cmake") then
            package:add("deps", "cmake")
            package:add("resources", "*", "cmake", "https://github.com/madler/zlib.git", "61a56bcbb0561e5c9a9a93af51d43e6a495b468f") -- 2025.02.01
        end

        if package:config("bzip2") then
            package:add("deps", "bzip2")
            package:add("defines", "HAVE_BZIP2=1")
        end
    end)

    on_install(function (package)
        os.cd(path.join("contrib/minizip"))

        local ndk_sdkver = package:toolchain("ndk"):config("ndk_sdkver")
        if ndk_sdkver and tonumber(ndk_sdkver) < 24 then
            io.replace("ioapi.c", "ftello", "ftell", {plain = true})
            io.replace("ioapi.c", "fseeko", "fseek", {plain = true})
        end

        if package:config("cmake") then
            local dir = path.join(package:resourcedir("cmake"), "contrib/minizip")
            os.vcp(path.join(dir, "CMakeLists.txt"), os.curdir())
            os.vcp(path.join(dir, "minizipConfig.cmake.in"), os.curdir())
            os.vcp(path.join(dir, "minizip.pc.in"), os.curdir())
            os.vcp(path.join(dir, "minizip.pc.txt"), os.curdir())

            io.replace("CMakeLists.txt", "return()", "", {plain = true})
            io.replace("CMakeLists.txt", "find_package(ZLIB REQUIRED CONFIG)", "find_package(ZLIB REQUIRED)", {plain = true})
            io.replace("CMakeLists.txt", "ZLIB::ZLIBSTATIC", "ZLIB::ZLIB", {plain = true})
            if package:version() and package:version():le("1.3.1") then
                io.replace("CMakeLists.txt", "ints.h", "", {plain = true})
                io.replace("CMakeLists.txt", "skipset.h", "", {plain = true})
            end

            local configs = {"-DMINIZIP_BUILD_TESTING=OFF", "-DCMAKE_INSTALL_INCLUDEDIR=include/minizip"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DMINIZIP_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DMINIZIP_BUILD_STATIC=" .. (not package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DMINIZIP_ENABLE_BZIP2=" .. (package:config("bzip2") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
        else
            local configs = {}
            configs.bzip2 = package:config("bzip2")
            os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
            import("package.tools.xmake", {anonymous = true}).install(package, configs)

            local config_version_file = path.join(package:installdir("lib"), "cmake", "minizip", "minizipConfigVersion.cmake")
            if xmake:version():lt("3.0.4") and package:is_plat("cross") and package:check_sizeof("void*") == "4" and os.exists(config_version_file) then
                io.replace(config_version_file, [[if("${CMAKE_SIZEOF_VOID_P}" STREQUAL "" OR "8" STREQUAL "")]], [[if("${CMAKE_SIZEOF_VOID_P}" STREQUAL "" OR "4" STREQUAL "")]], {plain = true})
                io.replace(config_version_file, [[if(NOT CMAKE_SIZEOF_VOID_P STREQUAL "8")]], [[if(NOT CMAKE_SIZEOF_VOID_P STREQUAL "4")]], {plain = true})
                io.replace(config_version_file, [[math(EXPR installedBits "8 * 8")]], [[math(EXPR installedBits "4 * 8")]], {plain = true})
            end
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("inflate", {includes = "zip.h"}))
    end)
