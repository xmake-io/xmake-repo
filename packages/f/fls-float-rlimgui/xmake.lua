package("fls-float-rlimgui")
    set_homepage("https://github.com/raylib-extras/rlImGui")
    set_description("A Custom Raylib build integration with DearImGui for floatengine")
    set_license("zlib")

    add_urls("https://github.com/raylib-extras/rlImGui.git")
    add_versions("2025.11.27", "dc7f97679a024eee8f5f009e77cc311748200415")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("fls-float-raylib")
    add_deps("imgui v1.92.5-docking", {configs = {wchar32 = true}})

    on_install("windows", "mingw", function (package)
        local renaming_rules = {
            { "ShowCursor(",  "rlShowCursor(" },
            { "HideCursor(",  "rlHideCursor(" },
            { "PlaySound(",   "rlPlaySound(" },
            { "StopSound(",   "rlStopSound(" },
            { "(Rectangle)",  "(rlRectangle)" },
            { "Rectangle{",   "rlRectangle{" },
            { "Rectangle;",   "rlRectangle;" },
            { "Rectangle ",   "rlRectangle " },
            { "CloseWindow(", "rlCloseWindow(" },
            { "LoadImage(",   "rlLoadImage(" },
            { "DrawText(",    "rlDrawText(" },
            { "DrawTextEx(",  "rlDrawTextEx(" },
        }

        for _, file in ipairs(table.join(os.files("**.cpp"), os.files("**.h"))) do
            for _, rule in ipairs(renaming_rules) do
                io.replace(file, rule[1], rule[2], {plain = true})
            end
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c99", "c++17")

            add_requires("fls-float-raylib")
            add_requires("imgui v1.92.5-docking", {configs = {wchar32 = true}})

            if is_plat("linux") then
                add_defines("_GLFW_X11", "_GNU_SOURCE")
            end

            target("rlImGui")
                set_kind("$(kind)")
                add_files("*.cpp")
                add_headerfiles("*.h", "(extras/**.h)")
                add_includedirs(".", {public = true})
                add_packages("fls-float-raylib", "imgui")
                add_defines("IMGUI_DISABLE_OBSOLETE_FUNCTIONS", "IMGUI_DISABLE_OBSOLETE_KEYIO")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                rlImGuiBegin();
            }
        ]]}, {includes = {"rlImGui.h"}, configs = {languages = "c++17"}}))
    end)
