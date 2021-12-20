package("imgui-sfml")

    set_homepage("https://github.com/eliasdaler/imgui-sfml")
    set_description("Dear ImGui binding for use with SFML")

    add_urls("https://github.com/eliasdaler/imgui-sfml/archive/refs/tags/$(version).tar.gz",
             "https://github.com/eliasdaler/imgui-sfml.git")

    add_versions("v2.5", "3775c9303f656297f2392e91ffae2021e874ee319b4139c60076d6f757ede109")

    add_deps("cmake")
    add_deps("imgui", {system = false, private = true})
    add_deps("sfml")

    on_install("macosx", "linux", "windows", "mingw", function (package)
        local configs = {"-DIMGUI_SFML_FIND_SFML=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        local imgui_sourcedir = package:dep("imgui"):cachedir()
        if imgui_sourcedir then
            local imguidir = import("lib.detect.find_path")("imgui.h", path.join(imgui_sourcedir, "source", "*"))
            if imguidir then
                table.insert(configs, "-DIMGUI_DIR=" .. imguidir)
            end
        end
        if package:is_plat("windows") and package:config("shared") then
            io.replace("CMakeLists.txt", "sfml-graphics", "sfml-graphics-s", {plain = true})
            io.replace("CMakeLists.txt", "sfml-system", "sfml-system-s", {plain = true})
            io.replace("CMakeLists.txt", "sfml-window", "sfml-window-s", {plain = true})
        end
        if package:is_plat("mingw") then
            io.replace("cmake/FindImGui.cmake", "NO_DEFAULT_PATH", "NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH")
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = "sfml"})
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
