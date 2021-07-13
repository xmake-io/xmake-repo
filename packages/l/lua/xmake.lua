package("lua")

    set_homepage("http://lua.org")
    set_description("A powerful, efficient, lightweight, embeddable scripting language.")

    add_urls("https://www.lua.org/ftp/lua-$(version).tar.gz", {version = function (version)
        return version:sub(2)
    end})
    add_urls("https://github.com/lua/lua.git")

    add_versions("v5.4.2", "11570d97e9d7303c0a59567ed1ac7c648340cd0db10d5fd594c09223ef2f524f")
    add_versions("v5.4.1", "4ba786c3705eb9db6567af29c91a01b81f1c0ac3124fdbf6cd94bdd9e53cca7d")
    add_versions("v5.3.6", "fc5fd69bb8736323f026672b1b7235da613d7177e72558893a0bdcd320466d60")
    add_versions("v5.2.3", "13c2fb97961381f7d06d5b5cea55b743c163800896fd5c5e2356201d3619002d")
    add_versions("v5.1.5", "2640fc56a795f29d28ef15e13c34a47e223960b0240e8cb0a82d9b0738695333")

    add_includedirs("include/lua")
    if not is_plat("windows") then
        add_syslinks("dl", "m")
    end

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("linux", "macosx", "windows", "android", "bsd", function (package)
        local sourcedir = os.isdir("src") and "src/" or "" -- for tar.gz or git source
        io.writefile("xmake.lua", format([[
            local sourcedir = "%s"
            target("lualib")
                set_kind("%s")
                set_basename("lua")
                add_headerfiles(sourcedir .. "*.h", {prefixdir = "lua"})
                add_files(sourcedir .. "*.c|lua.c|luac.c|onelua.c")
                add_defines("LUA_COMPAT_5_2", "LUA_COMPAT_5_1")
                if is_plat("linux", "bsd") then
                    add_defines("LUA_USE_LINUX")
                    add_defines("LUA_DL_DLOPEN")
                elseif is_plat("macosx") then
                    add_defines("LUA_USE_MACOSX")
                    add_defines("LUA_DL_DYLD")
                elseif is_plat("windows") then
                    -- Lua already detects Windows and sets according defines
                    if is_kind("shared") then
                        add_defines("LUA_BUILD_AS_DLL", {public = true})
                    end
                end

            target("lua")
                set_enabled(%s)
                set_kind("binary")
                add_files(sourcedir .. "lua.c")
                add_deps("lualib")
                if not is_plat("windows") then
                    add_syslinks("dl")
                end
        ]], sourcedir,
            package:config("shared") and "shared" or "static",
            is_plat(os.host()) and "true" or "false"))

        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end

        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        if is_plat(os.host()) then
            os.vrun("lua -e \"print('hello xmake!')\"")
        end
        assert(package:has_cfuncs("lua_getinfo", {includes = "lua.h"}))
    end)
