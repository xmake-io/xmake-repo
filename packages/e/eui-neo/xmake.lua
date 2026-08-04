package("eui-neo")
    set_homepage("https://github.com/sudoevolve/EUI-NEO")
    set_description("Cross-platform, high-performance, low-overhead C++17 GPUI framework")
    set_license("Apache-2.0")

    set_urls("https://github.com/lilyco-42/EUI-NEO.git")

    add_versions("v0.5.5", "df2399495a139a21290bf8a9288f5efba2c52bde")

    add_configs("window_backend", {description = "Window backend", default = "glfw", values = {"glfw", "sdl2"}})
    add_configs("render_backend", {description = "Render backend", default = "opengl", values = {"auto", "opengl", "vulkan"}})
    add_configs("shared", {description = "Build eui_neo as a shared library", default = false, type = "boolean"})
    add_configs("markdown", {description = "Enable MD4C Markdown parsing support", default = true, type = "boolean"})
    add_configs("vulkan_low_latency", {description = "Prefer low-latency Vulkan presentation", default = false, type = "boolean"})

    add_deps("freetype", "libpng", "zlib")

    on_load(function(package)
        if package:config("window_backend") == "glfw" then
            package:add("deps", "glfw")
        end
        if package:config("window_backend") == "sdl2" then
            package:add("deps", "sdl2")
        end
        if package:config("render_backend") == "vulkan" then
            package:add("deps", "vulkan")
        end
        if not package:is_plat("windows") then
            package:add("deps", "curl")
        end
    end)

    on_install(function(package)
        local configs = {}
        configs.window_backend = package:config("window_backend")
        configs.render_backend = package:config("render_backend")
        configs.shared = package:config("shared")
        configs.markdown = package:config("markdown")
        configs.vulkan_low_latency = package:config("vulkan_low_latency")
        configs.apps = false
        configs.user_apps = false
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            namespace app {
                const DslAppConfig& dslAppConfig() {
                    static const DslAppConfig config = DslAppConfig{}
                        .title("Test app")
                        .pageId("test_app")
                        .windowSize(1440, 920)
                        .fps(90.0);
                    return config;
                }
                void compose(eui::Ui& ui, const eui::Screen& screen) {
                    const bool compactHeader = screen.width < 850.0f;
                    const float headerHeight = compactHeader ? 118.0f : 92.0f;
                    ui.stack("root").size(screen.width, screen.height).content([&] {
                        ui.rect("root.background").size(screen.width, screen.height).build();
                    }).build();
                }
            }
            void test() {
                eui::Ui ui;
                ui.stack("root");
            }
        ]]}, {configs = {languages = "c++17"}, includes = "eui_neo.h"}))
    end)
