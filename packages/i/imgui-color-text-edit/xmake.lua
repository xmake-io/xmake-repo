package("imgui-color-text-edit")
    set_homepage("https://github.com/BalazsJako/ImGuiColorTextEdit")
    set_description("Colorizing text editor for ImGui")
    set_license("MIT")

    add_urls("https://github.com/BalazsJako/ImGuiColorTextEdit.git")
    add_versions("2019.06.15", "0a88824f7de8d0bd11d8419066caa7d3469395c4")

    add_deps("imgui")

    on_install("macosx", "linux", "windows", "mingw", "android", "iphoneos", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++11")
            add_requires("imgui")
            add_packages("imgui")
            target("imgui-color-text-edit")
                set_kind("$(kind)")
                add_files("*.cpp")
                add_headerfiles("*.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                TextEditor editor;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "TextEditor.h"}))
    end)
