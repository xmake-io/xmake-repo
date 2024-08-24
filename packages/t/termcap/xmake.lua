package("termcap")
    set_homepage("https://www.gnu.org/software/termcap")
    set_description("Enables programs to use display terminals in a terminal-independent manner")
    set_license("GPL-2.0-or-later")

    add_urls("https://ftp.gnu.org/gnu/termcap/termcap-$(version).tar.gz",
             "https://github.com/marcv81/termcap.git")

    add_versions("1.3.1", "91a0e22e5387ca4467b5bcb18edf1c51b930262fd466d5fda396dd9d26719100")

    add_patches("1.3.1", "patches/1.3.1/unistd_h.patch", "9a61b94c22d913ac4f5adf3e5735c07cb5e57eaa057f737bacb754215897cce0")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            includes("@builtin/check")
            check_cincludes("HAVE_FCNTL_H", "fcntl.h")
            check_cincludes("HAVE_UNISTD_H", "unistd.h")
            target("termcap")
                set_kind("$(kind)")
                add_files("*.c")
                add_headerfiles("*.h")
                add_defines("STDC_HEADERS")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("tgetent", {includes = "termcap.h"}))
    end)
