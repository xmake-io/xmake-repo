package("raygui")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/raysan5/raygui")
    set_description("A simple and easy-to-use immediate-mode gui library")
    set_license("zlib")

    add_urls("https://github.com/raysan5/raygui/archive/refs/tags/$(version).tar.gz",
             "https://github.com/raysan5/raygui.git")
    add_versions("3.0", "a510eb6efb524dfc8a1a7072bab3d4182a550f9fe86d315ff13a59cfc707f877")

    add_deps("raylib 4.x")

    add_defines("RAYGUI_IMPLEMENTATION")

    on_install("windows", "linux", "macosx", function (package)
        os.cp("src/*", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <raygui.h>
            void test() {
                InitWindow(100, 100, "hello world!");
                GuiSetStyle(TEXTBOX, TEXT_ALIGNMENT, GUI_TEXT_ALIGN_CENTER);
            }
        ]]}))
    end)
