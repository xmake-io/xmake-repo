package("raygui")
    set_homepage("https://github.com/raysan5/raygui")
    set_description("A simple and easy-to-use immediate-mode gui library")
    set_license("zlib")

    add_urls("https://github.com/raysan5/raygui/archive/refs/tags/$(version).tar.gz",
             "https://github.com/raysan5/raygui.git")
    add_versions("3.0", "a510eb6efb524dfc8a1a7072bab3d4182a550f9fe86d315ff13a59cfc707f877")

    add_deps("raylib 4.x")

    on_install("windows", "linux", "macosx", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            add_requires("raylib")
            target("raygui")
               set_kind("$(kind)")
               add_files("src/*.c")
               add_headerfiles("src/(**.h)")
               add_defines("RAYGUI_IMPLEMENTATION")
               add_packages("raylib")
               if is_plat("windows") and is_kind("shared") then
                    add_defines("BUILD_LIBTYPE_SHARED")
               end
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        os.cp("src/raygui.h", "src/raygui.c")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <raygui.h>
            void test() {
                InitWindow(100, 100, "hello world!");
                GuiSetStyle(TEXTBOX, TEXT_ALIGNMENT, GUI_TEXT_ALIGN_CENTER);
            }
        ]]}))
    end)
