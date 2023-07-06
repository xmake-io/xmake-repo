package("imgui-sfml")

    set_homepage("https://github.com/eliasdaler/imgui-sfml")
    set_description("Dear ImGui binding for use with SFML")

    add_urls("https://github.com/eliasdaler/imgui-sfml/archive/refs/tags/$(version).tar.gz",
             "https://github.com/eliasdaler/imgui-sfml.git")

    add_versions("v2.5", "3775c9303f656297f2392e91ffae2021e874ee319b4139c60076d6f757ede109")

    add_deps("cmake")
    add_deps("imgui 1.80")
    add_deps("opengl", {optional = true})

    if is_plat("windows", "mingw") then
        add_syslinks("imm32")
    end

    add_links("ImGui-SFML")

    on_load(function(package)
        if package:is_plat("linux") and package:config("shared") then
            package:add("deps", "sfml", {configs = {shared = true}})
        else
            package:add("deps", "sfml")
        end
        if package:is_plat("windows", "mingw") and package:config("shared") then
            package:add("defines", "IMGUI_SFML_SHARED_LIB=1")
        end
    end)

    on_install("macosx", "linux", "windows", "mingw", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            add_requires("imgui 1.80")
            if is_plat("linux") and is_kind("shared") then
                add_requires("sfml", {configs = {shared = true}})
            else
                add_requires("sfml")
            end
            add_requires("opengl", {optional = true})
            target("ImGui-SFML")
                set_kind("$(kind)")
                add_files("imgui-SFML.cpp")
                add_headerfiles("*.h")
                add_includedirs(".")
                add_packages("imgui", "sfml", "opengl")
                set_languages("c++11")
                add_defines("IMGUI_USER_CONFIG=\"imconfig-SFML.h\"")
                if is_plat("windows", "mingw") then
                    add_syslinks("imm32")
                    if is_kind("shared") then
                        add_defines("IMGUI_SFML_SHARED_LIB=1", "IMGUI_SFML_EXPORTS")
                    end
                end
                add_rules("utils.install.pkgconfig_importfiles")
                add_rules("utils.install.cmake_importfiles")
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "imgui.h"
            #include "imgui-SFML.h"
            #include <SFML/Graphics/CircleShape.hpp>
            #include <SFML/Graphics/RenderWindow.hpp>
            #include <SFML/System/Clock.hpp>
            #include <SFML/Window/Event.hpp>
            void test() {
                sf::RenderWindow window(sf::VideoMode(640, 480), "ImGui + SFML = <3");
                window.setFramerateLimit(60);
                ImGui::SFML::Init(window);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
