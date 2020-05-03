package("ncurses")

    set_homepage("https://www.gnu.org/software/ncurses/")
    set_description("A free software emulation of curses.")

    add_urls("ftp://ftp.invisible-island.net/ncurses/ncurses-$(version).tar.gz",
             "https://invisible-mirror.net/archives/ncurses/ncurses-$(version).tar.gz",
             "ftp://ftp.gnu.org/gnu/ncurses/ncurses-$(version).tar.gz")
    add_versions("6.1", "aa057eeeb4a14d470101eff4597d5833dcef5965331be3528c08d99cebaa0d17")

    add_configs("widec", { description = "Compile with wide-char/UTF-8 code.", default = true, type = "boolean"})

    add_includedirs("include/ncurses", "include")

    on_load(function (package)
        if package:config("widec") then
            package:add("links", "ncursesw", "formw", "panelw", "menuw")
        else
            package:add("links", "ncurses", "form", "panel", "menu")
        end
    end)

    on_install("linux", "macosx", function (package)
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
