package("pdcurses")
    set_homepage("https://pdcurses.org/")
    set_description("PDCurses - a curses library for environments that don't fit the termcap/terminfo model.")

    add_urls("https://github.com/wmcbrine/PDCurses/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wmcbrine/PDCurses.git")
    add_versions("3.9", "590dbe0f5835f66992df096d3602d0271103f90cf8557a5d124f693c2b40d7ec")

    on_install("linux", "macosx", "mingw", "windows", function (package)
        -- sdl1 sdl2 dos os2 windows x11
        os.cd("sdl2")
        import("package.tools.make").install(package)
        -- if package:is_plat("linux", "macosx") then
        --     import("package.tools.make").install(package, {})
        -- elseif package:is_plat("windows") then
        --     local configs = {"-f", "Makefile.vc", "WIDE=Y", "UTF8=Y"}
        --     if package:config("shared") then 
        --         table.insert(configs, "DLL=Y")
        --     end
        --     import("package.tools.nmake").install(package, configs)
        -- end

        -- local configs = {}
        -- io.writefile("xmake.lua", [[
        --     add_rules("mode.release", "mode.debug")
        --     target("pdcurses")
        --        set_kind("$(kind)")
        --        add_files("sdl2/*.h")
        --        add_files("sdl2/*.c")
        -- ]])
        -- if package:config("shared") then
        --     configs.kind = "shared"
        -- end
        -- import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        -- assert(package:has_cfuncs("foo", {includes = "foo.h"}))
    end)
