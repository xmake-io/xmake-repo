package("minizip")
    set_homepage("https://www.zlib.net/")
    set_description("Mini zip and unzip based on zlib")
    set_license("zlib")

    add_urls("https://github.com/madler/zlib/archive/$(version).tar.gz",
             "https://github.com/madler/zlib.git")
    add_versions("v1.2.10", "42cd7b2bdaf1c4570e0877e61f2fdc0bce8019492431d054d3d86925e5058dc5")
    add_versions("v1.2.11", "629380c90a77b964d896ed37163f5c3a34f6e6d897311f1df2a7016355c45eff")
    add_versions("v1.2.12", "d8688496ea40fb61787500e863cc63c9afcbc524468cedeb478068924eb54932")
    add_versions("v1.2.13", "1525952a0a567581792613a9723333d7f8cc20b87a81f920fb8bc7e3f2251428")

    add_deps("zlib")

    add_includedirs("include", "include/minizip")

    if on_check then
        on_check("android", function(package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) >= 24, "package(libmem): need ndk api level >= 24 for android")
        end)
    end

    on_install(function (package)
        os.cd(path.join("contrib", "minizip"))
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_rules("utils.install.cmake_importfiles")
            add_rules("utils.install.pkgconfig_importfiles")
            add_requires("zlib")
            target("minizip")
                set_kind("$(kind)")
                add_files("zip.c", "unzip.c", "mztools.c", "ioapi.c")
                add_headerfiles("crypt.h", "zip.h", "unzip.h", "ioapi.h", "mztools.h", {prefixdir = "minizip"})
                add_packages("zlib")
                if is_plat("windows") then
                    add_files("iowin32.c")
                    add_headerfiles("iowin32.h")
                else
                    add_defines("_LARGEFILE64_SOURCE=1", "_FILE_OFFSET_BITS=64")
                end
                on_config(function(target)
                    if not target:is_plat("windows") then
                        local snippet = target:has_cfuncs("fopen64", {includes = "stdio.h", configs = {languages = "c11"}})
                        if not snippet then
                            target:add("defines", "IOAPI_NO_64")
                        end
                    end
                end)
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        elseif not package:is_plat("windows", "mingw") and package:config("pic") ~= false then
            configs.cxflags = "-fPIC"
        end
        import("package.tools.xmake").install(package, configs)
        local config_version_file = path.join(package:installdir("lib"), "cmake", "minizip", "minizipConfigVersion.cmake")
        if package:is_plat("cross") and package:check_sizeof("void*") == "4" and os.exists(config_version_file) then
            io.replace(config_version_file, [[if("${CMAKE_SIZEOF_VOID_P}" STREQUAL "" OR "8" STREQUAL "")]], [[if("${CMAKE_SIZEOF_VOID_P}" STREQUAL "" OR "4" STREQUAL "")]], {plain = true})
            io.replace(config_version_file, [[if(NOT CMAKE_SIZEOF_VOID_P STREQUAL "8")]], [[if(NOT CMAKE_SIZEOF_VOID_P STREQUAL "4")]], {plain = true})
            io.replace(config_version_file, [[math(EXPR installedBits "8 * 8")]], [[math(EXPR installedBits "4 * 8")]], {plain = true})
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("inflate", {includes = "zip.h"}))
    end)
