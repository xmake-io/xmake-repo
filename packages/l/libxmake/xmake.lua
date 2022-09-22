package("libxmake")

    set_homepage("https://xmake.io")
    set_description("The c/c++ bindings of the xmake core engine")

    add_urls("https://github.com/xmake-io/xmake/releases/download/$(version)/xmake-$(version).tar.gz")
    add_urls("https://gitee.com/tboox/xmake.git",
             "https://github.com/xmake-io/xmake.git",
             "https://gitlab.com/tboox/xmake.git")

    add_versions("v2.5.9", "5b50e3f28956cabcaa153624c91781730387ceb7c056f3f9b5306b1c77460d8f")
    add_versions("v2.7.1", "e44085090641547d8814afcc345d641d8ce1e38b6e05fee7375fc88150c0803d")

    add_configs("readline", { description = "Enable readline library.", default = false, type = "boolean"})
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_includedirs("include")
    if is_plat("windows") then
        add_ldflags("/export:malloc", "/export:free", "/export:memmove")
        add_syslinks("kernel32", "user32", "gdi32")
        add_syslinks("ws2_32", "advapi32", "shell32")
        add_ldflags("/LTCG")
        add_shflags("/LTCG")
    elseif is_plat("android") then
        add_syslinks("m", "c")
    elseif is_plat("macosx") then
        add_ldflags("-all_load", "-pagezero_size 10000", "-image_base 100000000")
        add_frameworks("CoreFoundation", "CoreServices")
    else
        add_syslinks("pthread", "dl", "m", "c")
    end

    on_load(function (package)
        package:add("links", "xmake", "tbox", "sv", "lcurses")
        if package:is_plat("windows") then
            package:add("links", "pdcurses")
        else
            package:add("deps", "ncurses")
        end
        if package:config("readline") then
            package:add("links", "readline")
        end
        if package:debug() then
            package:add("defines", "__tb_debug__")
        end
        package:add("links", "lua-cjson", "lz4")
        if not package:gitref() and package:version():le("2.5.9") then
            package:add("includedirs", "include/luajit")
            package:add("links", "luajit")
        else
            package:add("includedirs", "include/lua")
            package:add("links", "lua")
        end
    end)

    on_install("linux", "macosx", "windows", function (package)
        local configs = {"--onlylib=y"}
        if package:is_plat("windows") then
            table.insert(configs, "--pdcurses=" .. (package:config("curses") and "y" or "n"))
        else
            table.insert(configs, "--curses=" .. (package:config("curses") and "y" or "n"))
        end
        if not package:gitref() and package:version():le("2.5.9") then
            io.replace("core/src/luajit/xmake.lua", "set_default(false)", "", {plain = true})
        end
        table.insert(configs, "--readline=" .. (package:config("readline") and "y" or "n"))
        os.cd("core")
        io.replace("xmake.lua", 'set_warnings("all", "error")', "", {plain = true})
        import("package.tools.xmake").install(package, configs)
        os.cp("../xmake", package:installdir("share"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xm_engine_init", {includes = "xmake/xmake.h"}))
    end)
