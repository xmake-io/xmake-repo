package("imgui-color-text-edit")
    set_homepage("https://github.com/BalazsJako/ImGuiColorTextEdit")
    set_description("Colorizing text editor for ImGui")
    set_license("MIT")

    add_urls("https://github.com/BalazsJako/ImGuiColorTextEdit.git")
    add_versions("2019.06.15", "0a88824f7de8d0bd11d8419066caa7d3469395c4")

    add_deps("imgui <1.91")

    on_install("macosx", "linux", "windows", "mingw", "android", "iphoneos", function (package)
        -- Fix GCC15
        io.replace("TextEditor.h", [[#include "imgui.h"]], [[#include "imgui.h"
#include <cstdint>]], {plain = true})
        local imgui = package:dep("imgui")
        local configs = imgui:requireinfo().configs
        if configs then
            configs = string.serialize(configs, {strip = true, indent = false})
        end
        io.writefile("xmake.lua", format([[
            add_rules("mode.debug", "mode.release")
            set_languages("c++11")
            add_requires("imgui %s", {configs = %s})
            add_packages("imgui")
            target("imgui-color-text-edit")
                set_kind("$(kind)")
                add_files("*.cpp")
                add_headerfiles("*.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]], imgui:version_str(), configs))
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                TextEditor editor;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "TextEditor.h"}))
    end)
