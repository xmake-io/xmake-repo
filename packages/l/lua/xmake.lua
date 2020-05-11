package("lua")

    set_homepage("http://lua.org")
    set_description("A powerful, efficient, lightweight, embeddable scripting language.")

    set_urls("https://www.lua.org/ftp/lua-$(version).tar.gz",
             "https://github.com/lua/lua.git")

    add_versions("5.3.5", "0c2eed3f960446e1a3e4b9a1ca2f3ff893b6ce41942cf54d5dd59ab4b3b058ac")
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
            target("lualib")
                set_kind("%s")
                set_basename("lua")
                add_headerfiles("src/*.h", {prefixdir = "lua"})
                add_files("src/*.c|lua.c|luac.c")
                add_defines("LUA_COMPAT_5_2", "LUA_COMPAT_5_1")
                add_defines("LUA_DL_DLL")
                if is_plat("linux") then
                    add_defines("LUA_USE_LINUX")
                elseif is_plat("macosx") then
                    add_defines("LUA_USE_MACOSX")
                elseif is_plat("windows") then
                    add_defines("LUA_USE_WINDOWS")
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
