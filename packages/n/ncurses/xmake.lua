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
    add_versions("6.5", "136d91bc269a9a5785e5f9e980bc76ab57428f604ce3e5a5a90cebc767971cc6")
    add_versions("6.6", "355b4cbbed880b0381a04c46617b7656e362585d52e9cf84a67e2009b749ff11")

    add_configs("widec", {description = "Compile with wide-char/UTF-8 code.", default = true, type = "boolean"})

    if is_plat("linux") then
        add_extsources("apt::libncurses-dev")
    end

    if on_check then
        on_check("mingw", function(package)
            if is_subhost("macosx") then
                assert(package:version():lt("6.6"), "package(ncurses >= 6.6): unsupported version on mingw@macosx.")
            end
        end)
    end

    on_load(function (package)
        if package:is_cross() then
            package:add("deps", "ncurses", {private = true, host = true})
        end
        if package:config("widec") then
            package:add("links", "ncursesw", "formw", "panelw", "menuw")
            package:add("includedirs", "include/ncursesw", "include")
        else
            package:add("links", "ncurses", "form", "panel", "menu")
            package:add("includedirs", "include/ncurses", "include")
        end

        if not package:config("shared") then
            package:add("defines", "NCURSES_STATIC")
        end
    end)

    on_install("!wasm and !iphoneos and @!windows", function (package)
        local configs = {
            "--without-manpages",
            "--enable-sigwinch",
            -- Prevent `strip` command issues with cross-compiled binaries
            "--disable-stripping",
            "--with-gpm=no",
            "--without-tests",
            "--without-ada",
            "--enable-pc-files",
            "--with-pkg-config-libdir=" .. path.unix(package:installdir("lib", "pkgconfig")):gsub("^(%a):", "/%1"),
        }

        table.insert(configs, "--with-debug=" .. (package:is_debug() and "yes" or "no"))
        table.insert(configs, "--with-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-widec=" .. (package:config("widec") and "yes" or "no"))
        if not package:is_cross() then
            package:addenv("PATH", "bin")
        else
            local ncurses_host = package:dep("ncurses")
            if ncurses_host then
                local tic = path.join(ncurses_host:installdir("bin"), "tic" .. (is_host("windows") and ".exe" or ""))
                if os.isexec(tic) then
                    table.insert(configs, "--with-tic-path=" .. path.unix(tic))
                end
            end
        end

        local cflags = {}
        if package:version():le("6.6") then
            table.insert(cflags, "-std=c17")
        end

        if package:is_plat("mingw", "cygwin", "msys") then
            table.insert(configs, "--enable-term-driver")
            table.insert(cflags, "-D__USE_MINGW_ACCESS") -- Pass X_OK to access() on Windows which isn't supported with ucrt
        end
        import("package.tools.autoconf").install(package, configs, {cflags = cflags, arflags = {"-curvU"}})
        for _, file in ipairs(os.files(path.join(package:installdir("include"), "**.h"))) do
            io.replace(file, "#include <ncursesw/(.-)>", '#include "%1"', {plain = false})
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("initscr", {includes = "curses.h"}))
    end)
