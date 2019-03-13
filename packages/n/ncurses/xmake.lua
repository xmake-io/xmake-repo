package("ncurses")

    set_homepage("https://www.gnu.org/software/ncurses/")
    set_description("A free software emulation of curses.")

    add_urls("ftp://ftp.invisible-island.net/ncurses/ncurses-$(version).tar.gz",
             "https://invisible-mirror.net/archives/ncurses/ncurses-$(version).tar.gz",
             "ftp://ftp.gnu.org/gnu/ncurses/ncurses-$(version).tar.gz")
    add_versions("6.1", "aa057eeeb4a14d470101eff4597d5833dcef5965331be3528c08d99cebaa0d17")

    add_includedirs("include/ncurses", "include")
    add_links("ncurses", "form", "panel", "menu")

    on_install("linux", "macosx", function (package)
        import("package.tools.autoconf").install(package, {"--without-manpages"})
    end)
