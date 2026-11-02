package("rtxui")
    set_homepage("https://github.com/ArthurSonzogni/RTXUI")
    set_description("C++ terminal user interfaces built from HTML templates, CSS and reactive state")
    set_license("MIT")

    add_urls("https://github.com/ArthurSonzogni/RTXUI/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ArthurSonzogni/RTXUI.git")
    add_versions("v0.1.3", "b9fdef7b50c8c70a74451e46d0a1a120d93a0badf6817e87ba33a5a72804cba4")
    add_patches("v0.1.3", "https://github.com/ArthurSonzogni/RTXUI/commit/796aec61ea8dcbf819d098aa238798739820726b.patch", "0640d11efba4d79900bfdb5f2e75fd8e48f492e8b2ab5f30cd3f093b4248ba0d")

    add_deps("cmake")

    if is_plat("windows", "mingw") then
        add_syslinks("gdi32", "user32")
    end

    if is_plat("macosx") then
        add_defines("_LIBCPP_DISABLE_AVAILABILITY")
    end

    on_install("linux", "macosx", "windows", "mingw", function (package)
        local configs = {
            "-DRTXUI_BUILD_TESTS=OFF",
            "-DRTXUI_BUILD_EXAMPLES=OFF",
            "-DRTXUI_BUILD_FUZZERS=OFF",
            "-DRTXUI_BUILD_BENCHMARKS=OFF",
        }
        local opt = {}
        if package:is_plat("macosx") then
            opt.cxflags = "-D_LIBCPP_DISABLE_AVAILABILITY"
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, opt)
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
