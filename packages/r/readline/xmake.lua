package("readline")
    set_homepage("https://tiswww.case.edu/php/chet/readline/rltop.html")
    set_description("Library for command-line editing")
    set_license("GPL-3.0-or-later")

    add_urls("https://ftpmirror.gnu.org/readline/readline-$(version).tar.gz",
             "https://ftp.gnu.org/gnu/readline/readline-$(version).tar.gz")
    add_versions("8.1", "f8ceb4ee131e3232226a17f51b164afc46cd0b9e6cef344be87c65962cb82b02")

    add_deps("ncurses")

    on_install("linux", "macosx", function (package)
        local configs = {"--with-curses"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("readline", {includes = {"stdio.h", "readline/readline.h"}}))
    end)
