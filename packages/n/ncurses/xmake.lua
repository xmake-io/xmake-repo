package("ncurses")

    set_homepage("https://www.gnu.org/software/ncurses/")
    set_description("A free software emulation of curses.")

    add_urls("ftp://ftp.invisible-island.net/ncurses/ncurses-$(version).tar.gz",
             "https://invisible-mirror.net/archives/ncurses/ncurses-$(version).tar.gz",
             "ftp://ftp.gnu.org/gnu/ncurses/ncurses-$(version).tar.gz")
    add_versions("6.1", "aa057eeeb4a14d470101eff4597d5833dcef5965331be3528c08d99cebaa0d17")
    add_versions("6.2", "30306e0c76e0f9f1f0de987cf1c82a5c21e1ce6568b9227f7da5b71cbea86c9d")

    add_configs("widec", { description = "Compile with wide-char/UTF-8 code.", default = true, type = "boolean"})

    on_load(function (package)
        if package:config("widec") then
            package:add("links", "ncursesw", "formw", "panelw", "menuw")
            package:add("includedirs", "include/ncursesw", "include")
        else
            package:add("links", "ncurses", "form", "panel", "menu")
            package:add("includedirs", "include/ncurses", "include")
        end
    end)
 
    on_install("linux", "macosx", "bsd", function (package)
        local configs = {"--without-manpages", "--enable-sigwinch", "--with-gpm=no"}
        if package:config("widec") then
            table.insert(configs, "--enable-widec")
        end
        if package:config("shared") then
            table.insert(configs, "--with-shared")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("initscr", {includes = "curses.h"}))
    end)
