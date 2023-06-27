package("ncurses")

    set_homepage("https://invisible-island.net/ncurses/")
    set_description("A free software emulation of curses.")
    set_license("MIT")

    add_urls("https://ftpmirror.gnu.org/ncurses/ncurses-$(version).tar.gz",
             "https://ftp.gnu.org/pub/gnu/ncurses/ncurses-$(version).tar.gz",
             "https://invisible-mirror.net/archives/ncurses/ncurses-$(version).tar.gz")
    add_versions("6.1", "aa057eeeb4a14d470101eff4597d5833dcef5965331be3528c08d99cebaa0d17")
    add_versions("6.2", "30306e0c76e0f9f1f0de987cf1c82a5c21e1ce6568b9227f7da5b71cbea86c9d")
    add_versions("6.3", "97fc51ac2b085d4cde31ef4d2c3122c21abc217e9090a43a30fc5ec21684e059")
    add_versions("6.4", "6931283d9ac87c5073f30b6290c4c75f21632bb4fc3603ac8100812bed248159")

    add_configs("widec", {description = "Compile with wide-char/UTF-8 code.", default = true, type = "boolean"})

    if is_plat("linux") then
        add_extsources("apt::libncurses-dev")
    end
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
        table.insert(configs, "--with-debug=" .. (package:debug() and "yes" or "no"))
        if package:config("widec") then
            table.insert(configs, "--enable-widec")
        end
        if package:config("shared") then
            table.insert(configs, "--with-shared")
        end
        import("package.tools.autoconf").install(package, configs, {arflags = {"-curvU"}})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("initscr", {includes = "curses.h"}))
    end)
