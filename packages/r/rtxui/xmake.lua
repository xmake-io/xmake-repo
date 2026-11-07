package("rtxui")
    set_homepage("https://github.com/ArthurSonzogni/RTXUI")
    set_description("C++ terminal user interfaces built from HTML templates, CSS and reactive state")
    set_license("MIT")

    add_urls("https://github.com/ArthurSonzogni/RTXUI/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ArthurSonzogni/RTXUI.git")
    add_versions("v0.1.4", "8f1d22342dce4160d99576b7653bb511c7d3d74aabadf9064493fb816d669707")

    add_deps("cmake")

    if is_plat("windows", "mingw") then
        add_syslinks("gdi32", "user32")
    end

    on_install("linux", "windows", "mingw", function (package)
        local configs = {
            "-DRTXUI_BUILD_TESTS=OFF",
            "-DRTXUI_BUILD_EXAMPLES=OFF",
            "-DRTXUI_BUILD_FUZZERS=OFF",
            "-DRTXUI_BUILD_BENCHMARKS=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <rtxui/rtxui.hpp>
            #include <string_view>

            class App : public rtxui::Component<App> {
             public:
              int count = 0;
              std::string_view view = "<button>{count}</button>";
              App() { Bind(count); }
            };

            void test() {
              rtxui::HeadlessScreen screen(rtxui::Ref<App>::New(), 20, 3);
              screen.Text();
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
