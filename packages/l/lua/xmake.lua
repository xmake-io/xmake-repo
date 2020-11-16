package("lua")

    set_homepage("http://lua.org")
    set_description("A powerful, efficient, lightweight, embeddable scripting language.")

    set_urls("https://www.lua.org/ftp/lua-$(version).tar.gz",
             "https://github.com/lua/lua.git")

    add_versions("5.4.1", "4ba786c3705eb9db6567af29c91a01b81f1c0ac3124fdbf6cd94bdd9e53cca7d")
    add_versions("5.3.6", "fc5fd69bb8736323f026672b1b7235da613d7177e72558893a0bdcd320466d60")
    add_versions("5.2.4", "b9e2e4aad6789b3b63a056d442f7b39f0ecfca3ae0f1fc0ae4e9614401b69f4b")
    add_versions("5.1.5", "2640fc56a795f29d28ef15e13c34a47e223960b0240e8cb0a82d9b0738695333")

    add_includedirs("include/lua")
    if not is_plat("windows") then
        add_syslinks("dl", "m")
    end

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("linux", "macosx", "windows", "android", "bsd", function (package)
        io.writefile("xmake.lua", format([[
            local kind = "%s"

            target("lualib")
                set_kind(kind)
                set_basename("lua")
                add_headerfiles("src/*.h", {prefixdir = "lua"})
                add_files("src/*.c|lua.c|luac.c")
                add_defines("LUA_COMPAT_5_2", "LUA_COMPAT_5_1")
                if is_plat("linux", "bsd") then
                    add_defines("LUA_USE_LINUX")
                    add_defines("LUA_DL_DLOPEN")
                elseif is_plat("macosx") then
                    add_defines("LUA_USE_MACOSX")
                    add_defines("LUA_DL_DYLD")
                elseif is_plat("windows") then
                    -- Lua already detects Windows and sets according defines
                    if kind == "shared" then
                        add_defines("LUA_BUILD_AS_DLL", {public = true})
                    end
                end

            target("lua")
                set_enabled(%s)
                set_kind("binary")
                add_files("src/lua.c")
                add_deps("lualib")
                if not is_plat("windows") then
                    add_syslinks("dl")
                end
        ]], package:config("shared") and "shared" or "static", is_plat(os.host()) and "true" or "false"))
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        if is_plat(os.host()) then
            os.vrun("lua -e \"print('hello xmake!')\"")
        end
        assert(package:has_cfuncs("lua_getinfo", {includes = "lua.h"}))
    end)
