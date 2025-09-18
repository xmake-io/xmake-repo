package("ftxui")
    set_homepage("https://github.com/ArthurSonzogni/FTXUI")
    set_description(":computer: C++ Functional Terminal User Interface. :heart:")
    set_license("MIT")

    add_urls("https://github.com/ArthurSonzogni/FTXUI/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ArthurSonzogni/FTXUI.git")
    add_versions("v6.1.9", "45819c1e54914783d4a1ca5633885035d74146778a1f74e1213cdb7b76340e71")
    add_versions("v6.1.1", "eb3546cc662c18f0c3f54ece72618fe43905531d2088e4ba8081983fa8986b95")
    add_versions("v6.0.2", "ace3477a8dd7cdb911dbc75e7b43cdcc9cf1d4a3cc3fb41168ecc31c06626cb9")
    add_versions("v5.0.0", "a2991cb222c944aee14397965d9f6b050245da849d8c5da7c72d112de2786b5b")
    add_versions("v4.1.1", "9009d093e48b3189487d67fc3e375a57c7b354c0e43fc554ad31bec74a4bc2dd")
    add_versions("v3.0.0", "a8f2539ab95caafb21b0c534e8dfb0aeea4e658688797bb9e5539729d9258cc1")

    add_deps("cmake")

    add_configs("modules", { default = false, type = "boolean" })
    add_configs("microsoft_fallback_terminal", { default = true, description = "On windows, assume the \
terminal used will be one of Microsoft and use a set of reasonnable fallback \
to counteract its implementations problems.", type = "boolean" })

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    elseif is_plat("bsd") then
        add_syslinks("pthread")
    end

    add_components("screen", "dom", "component")

    on_load(function(package)
        if package:config("modules") then
            assert(package:gitref() or (package:version() and package:version():gt("1.0")), "modules support is not compatible with ftxui <= 1.0")
        end
    end)

    on_component("screen", function(_, component)
        component:add("links","ftxui-screen")
    end)

    on_component("dom", function(_, component)
        component:add("links", "ftxui-dom")
        component:add("deps", "screen")
    end)

    on_component("component", function(_, component)
        component:add("links", "ftxui-component")
        component:add("deps", "dom")
    end)

    on_install("linux", "windows", "macosx", "bsd", "mingw", "cross", function (package)
        if package:config("modules") then
            os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), ".")
            import("package.tools.xmake").install(package, {modules = package:config("modules"), microsoft_fallback_terminal = package:config("microsoft_fallback_terminal")})
        else
            local configs = {"-DFTXUI_BUILD_DOCS=OFF", "-DFTXUI_BUILD_EXAMPLES=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DFTXUI_MICROSOFT_TERMINAL_FALLBACK=" .. (package:config("microsoft_fallback_terminal") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <memory>
            #include <string>

            #include "ftxui/component/captured_mouse.hpp"
            #include "ftxui/component/component.hpp"
            #include "ftxui/component/component_base.hpp"
            #include "ftxui/component/screen_interactive.hpp"
            #include "ftxui/dom/elements.hpp"

            using namespace ftxui;

            void test() {
                int value = 50;
                auto buttons = Container::Horizontal({
                  Button("Decrease", [&] { value--; }),
                  Button("Increase", [&] { value++; }),
                });
                auto component = Renderer(buttons, [&] {
                return vbox({
                           text("value = " + std::to_string(value)),
                           separator(),
                           gauge(value * 0.01f),
                           separator(),
                           buttons->Render(),
                       }) |
                       border;
                });
                auto screen = ScreenInteractive::FitComponent();
                screen.Loop(component);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
