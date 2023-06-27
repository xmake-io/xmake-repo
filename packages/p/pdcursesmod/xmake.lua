package("pdcursesmod")
    set_homepage("https://projectpluto.com/win32a.htm")
    set_description("PDCurses Modified - a curses library modified and extended from the 'official' pdcurses")

    add_urls("https://github.com/Bill-Gray/PDCursesMod/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Bill-Gray/PDCursesMod.git")
    add_versions("v4.3.4", "abbd099a51612200d1bfe236d764e0f0748ee71c3a6bc2c4069447d907d55b82")

    if not is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_configs("port", {description = "Set the target port.", default = "sdl2", values = {"sdl2", "wincon"}})
    add_configs("utf8", {description = "Treat all narrow characters as UTF-8.", default = true, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("user32", "advapi32", "winmm")
    end

    on_load(function (package)
        if package:config("port") == "sdl2" then
            package:add("deps", "libsdl")
            if package:config("utf8") then
                package:add("deps", "libsdl_ttf")
            end
        end
        if package:config("utf8") then
            package:add("defines", "PDC_WIDE", "PDC_FORCE_UTF8")
        end
        if package:config("shared") then
            package:add("defines", "PDC_DLL_BUILD")
        end
    end)
    
    on_install("linux", "macosx", "mingw", "windows", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            option("port", {description = "Set the target port."})
            option("utf8", {description = "Treat all narrow characters as UTF-8."})
                add_defines("PDC_WIDE", "PDC_FORCE_UTF8")
            if is_config("port", "sdl2") then
                add_requires("libsdl")
                if has_config("utf8") then
                    add_requires("libsdl_ttf")
                end
            end
            target("pdcursesmod")
                set_kind("$(kind)")
                add_files("pdcurses/*.c", "$(port)/*.c")
                add_includedirs(".", "$(port)")
                add_headerfiles("*.h", "$(port)/*.h")
                if is_kind("shared") then
                    add_defines("PDC_DLL_BUILD")
                end
                add_packages("libsdl", "libsdl_ttf")
                if is_plat("windows", "mingw") then
                    add_syslinks("user32", "advapi32", "winmm")
                end
        ]])
        local configs = {}
        if package:config("shared") then 
            configs.kind = "shared"
        end
        configs.port = package:config("port")
        configs.utf8 = package:config("utf8")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets([[
            void test(void) {
                initscr();
                printw("Hello, world!");
                refresh();
                endwin();
            }
        ]], {includes = "curses.h"}))
    end)
