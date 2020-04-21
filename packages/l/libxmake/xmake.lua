package("libxmake")

    set_homepage("https://xmake.io")
    set_description("The c/c++ bindings of the xmake core engine")

    add_urls("https://gitee.com/tboox/xmake.git",
             "https://github.com/xmake-io/xmake.git",
             "https://gitlab.com/tboox/xmake.git")

    add_configs("curses",   { description = "Enable curses library.", default = false, type = "boolean"})
    add_configs("readline", { description = "Enable readline library.", default = false, type = "boolean"})

    add_includedirs("include", "include/luajit")
    add_links("xmake", "tbox", "luajit", "sv")
    if is_plat("windows") then
        add_ldflags("/export:malloc", "/export:free")
        add_syslinks("kernel32", "user32", "gdi32")
        add_syslinks("ws2_32", "advapi32", "shell32")
    elseif is_plat("android") then
        add_syslinks("m", "c")
    elseif is_plat("macosx") then
        add_ldflags("-all_load", "-pagezero_size 10000", "-image_base 100000000")
    elseif is_plat("msys") then
        add_ldflags("-static-libgcc", {force = true})
        add_syslinks("kernel32", "user32", "gdi32")
        add_syslinks("ws2_32", "advapi32", "shell32")
    else
        add_syslinks("pthread", "dl", "m", "c")
    end

    on_load(function (package)
        if package:config("curses") then
            package:add("links", "lcurses")
            if package:is_plat("windows") then
                package:add("links", "pdcurses")
            else
                package:add_deps("ncurses")
            end
        end
        if package:config("readline") then
            package:add("links", "readline")
        end
    end)

    on_install("linux", "macosx", "windows", "msys", "android", function (package)
        local configs = {"--onlylib=y"}
        if package:is_plat("windows") then
            table.insert(configs, "--pdcurses=" .. (package:config("curses") and "y" or "n"))
        else
            table.insert(configs, "--curses=" .. (package:config("curses") and "y" or "n"))
        end
        table.insert(configs, "--readline=" .. (package:config("readline") and "y" or "n"))
        os.cd("core")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xm_engine_init", {includes = "xmake/xmake.h"}))
    end)
