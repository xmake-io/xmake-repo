package("readline")
    set_homepage("https://tiswww.case.edu/php/chet/readline/rltop.html")
    set_description("Library for command-line editing")
    set_license("GPL-3.0-or-later")

    add_urls("https://ftpmirror.gnu.org/readline/readline-$(version).tar.gz",
             "https://ftp.gnu.org/gnu/readline/readline-$(version).tar.gz")

    add_versions("8.2.13", "0e5be4d2937e8bd9b7cd60d46721ce79f88a33415dd68c2d738fb5924638f656")
    add_versions("8.2", "3feb7171f16a84ee82ca18a36d7b9be109a52c04f492a053331d7d1095007c35")
    add_versions("8.1", "f8ceb4ee131e3232226a17f51b164afc46cd0b9e6cef344be87c65962cb82b02")

    if is_plat("mingw", "cygwin", "msys") then
        add_patches("8.2.13", "patches/8.2.13/mingw_fd_set.patch", "3b5576e51471b248f5c89e0d4c01ac0bc443a239169fa19e25980f9a923f659a")
    end

    add_deps("ncurses")

    on_install("!wasm and !iphoneos and @!windows", function (package)
        local configs = {"--with-curses", "--disable-install-examples"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))

        io.replace("support/shobj-conf", "-Wl,-rpath,$(libdir)", "", {plain = true}) -- Remove RPATH from shared objects (FS#14366)
        local makefile_inputs = {"Makefile.in", "shlib/Makefile.in"}
        local SHLIB_LIBS = package:dep("ncurses"):config("widec") and "-lncursesw" or "-lncurses"
        for _, makefile_input in ipairs(makefile_inputs) do
            io.replace(makefile_input, "@SHLIB_LIBS@", SHLIB_LIBS, {plain = true})
        end
        if is_host("windows") then
            -- Avoid issues with /c/dir style paths
            for _, makefile_input in ipairs(makefile_inputs) do
                io.replace(makefile_input, "@BUILD_DIR@", path.unix(os.curdir()), {plain = true}) -- C:/dir
            end
        end

        local cflags = {}
        if package:version():le("8.2.13") then
            table.insert(cflags, "-std=c17")
        end
        if package:is_plat("mingw", "cygwin", "msys") then
            table.insert(cflags, "-DNEED_EXTERN_PC=1") -- Use extern PC variable from ncurses
            table.join2(cflags, {"-D__USE_MINGW_ALARM", "-D_POSIX"}) -- Make mingw-w64 provide a dummy alarm() function
            io.replace("support/shobj-conf", "--export-all", "--export-all-symbols", {plain = true})
        end
        import("package.tools.autoconf").install(package, configs, {cflags = cflags, packagedeps = {"ncurses"}})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("readline", {includes = {"stdio.h", "readline/readline.h"}}))
    end)
