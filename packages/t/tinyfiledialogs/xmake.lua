package("tinyfiledialogs")

    set_homepage("https://sourceforge.net/projects/tinyfiledialogs/")
    set_description("Native dialog library for WINDOWS MAC OSX GTK+ QT CONSOLE")
    set_license("zlib")

    add_urls("https://git.code.sf.net/p/tinyfiledialogs/code.git")
    add_versions("3.8.8", "d89567798fb1b989c6fc46a61698e4734760e0bf")
    add_versions("3.15.1", "776ad52d7b7057f330caa74f00e5e9d9eae85631")

    if is_plat("windows") then
        add_syslinks("comdlg32", "ole32", "user32", "shell32")
    end
    on_install("windows", "linux", "macosx", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("tinyfiledialogs")
                set_kind("static")
                add_files("tinyfiledialogs.c")
                add_headerfiles("tinyfiledialogs.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <stdio.h>
            #include <string.h>
            #include "tinyfiledialogs.h"
            void test() {
                char const * lWillBeGraphicMode;
                lWillBeGraphicMode = tinyfd_inputBox("tinyfd_query", NULL, NULL);
            }
        ]]}))
    end)
