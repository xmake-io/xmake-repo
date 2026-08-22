package("rlimgui")
    set_homepage("https://github.com/raylib-extras/rlImGui")
    set_description("A Raylib integration with DearImGui")
    set_license("zlib")

    add_urls("https://github.com/raylib-extras/rlImGui.git")
    add_versions("2025.11.27", "dc7f97679a024eee8f5f009e77cc311748200415")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("raylib")
    add_deps("imgui", {configs = {docking = true, wchar32 = true}})

    on_install("!cross and !bsd and !iphoneos", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c99", "c++17")

            add_requires("raylib")
            add_requires("imgui", {configs = {docking = true, wchar32 = true}})

            if is_plat("linux") then
                add_defines("_GLFW_X11", "_GNU_SOURCE")
            end

            target("rlImGui")
                set_kind("$(kind)")
                add_files("*.cpp")
                add_headerfiles("*.h", "(extras/**.h)")
                add_includedirs(".", {public = true})
                add_packages("raylib", "imgui")
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
