package("pdcurses")
    set_homepage("https://pdcurses.org/")
    set_description("PDCurses - a curses library for environments that don't fit the termcap/terminfo model.")

    add_urls("https://github.com/wmcbrine/PDCurses/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wmcbrine/PDCurses.git")
    add_versions("3.9", "590dbe0f5835f66992df096d3602d0271103f90cf8557a5d124f693c2b40d7ec")

    if not is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end
    
    add_deps("libsdl")

    on_install("linux", "macosx", "mingw", "windows", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("libsdl")
            target("pdcurses")
                set_kind("$(kind)")
                add_files("pdcurses/*.c", "sdl2/*.c")
                add_includedirs(".", "sdl2")
                add_headerfiles("*.h", "sdl2/*.h")
                add_packages("libsdl")
        ]])
        local configs = {}
        if package:config("shared") then 
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cincludes("curses.h"))
    end)
