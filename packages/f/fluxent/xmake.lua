package("fluxent")
    set_homepage("https://github.com/Project-Xent/fluxent")
    set_description("A lightweight Windows UI framework in modern C++.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/Project-Xent/fluxent.git")
    add_versions("2026.01.30", "6bf7e68893aaabe0d389e58cb2f5711e5e76aadb")

    add_deps("xent-core", "tl_expected")

    on_install("windows", function (package)
        io.replace("include/fluxent/types.hpp", [[#include "../../third_party/tl/expected.hpp"]], [[#include <tl/expected.hpp>]], {plain = true})
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++20")
            add_defines("_WIN32_WINNT=0x0A00", "WINVER=0x0A00", "UNICODE", "_UNICODE", "WIN32_LEAN_AND_MEAN", "NOMINMAX")
            add_requires("xent-core", "tl_expected")
            target("fluxent")
                set_kind("$(kind)")
                add_includedirs("include")
                add_headerfiles("include/fluxent/(**.hpp)", {prefixdir = "fluxent"})
                add_packages("xent-core", "tl_expected")
                add_files("src/*.cpp", "src/theme/*.cpp", "src/controls/*.cpp")
                if is_plat("windows", "mingw") then
                    add_syslinks("user32", "gdi32", "dcomp", "d2d1", "d3d11", "dxgi", "dwrite", "dwmapi", "ole32", "uuid", "uxtheme")
                end
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <fluxent/fluxent.hpp>
            using namespace fluxent;
            void test() {
                fluxent::WindowConfig config;
                config.title = L"Hello FluXent";
                config.width = 400;
                config.height = 600;
                config.backdrop = fluxent::BackdropType::Mica;
                fluxent::theme::ThemeManager theme_manager;
                auto window_res = fluxent::Window::Create(&theme_manager, config);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
