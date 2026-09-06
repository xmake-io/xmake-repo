package("eui-neo")
    set_homepage("https://github.com/sudoevolve/EUI-NEO")
    set_description("Cross-platform, high-performance, low-overhead C++17 GPUI framework")
    set_license("Apache-2.0")

    add_urls("https://github.com/sudoevolve/EUI-NEO/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sudoevolve/EUI-NEO.git")

    add_versions("v0.5.9", "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
    add_versions("v0.5.8", "ca886cfb62bc05a849d2176bd6b30bbf2d0e14e1f866305ce622af6177548c8c")
    add_versions("v0.5.7", "2d3ec0a36e34b98d13dbdaf67afa4fe178cb4b52841eb17529517cb48be43551")
    add_versions("v0.5.6", "0df8d79897a480566b0989060f206431d12c4a83eb7aef50b8e5d21f1676abf8")
    add_versions("v0.5.5", "cf0da91d7544fe406b704922137fd4d55ed080b3e647501e0ca5303abb00eb98")

    add_configs("window_backend", {description = "Window backend", default = "glfw", values = {"glfw", "sdl2"}})
    add_configs("render_backend", {description = "Render backend", default = "opengl", values = {"auto", "opengl", "vulkan"}})
    add_configs("app_runner", {description = "Build the EUI application runner (defines main)", default = false, type = "boolean"})
    add_configs("markdown", {description = "Enable MD4C Markdown parsing support", default = true, type = "boolean"})
    add_configs("tray", {description = "Enable the system tray backend", default = true, type = "boolean"})
    add_configs("vulkan_low_latency", {description = "Prefer low-latency Vulkan presentation", default = false, type = "boolean"})

    add_deps("freetype", "libpng", "zlib", "yyjson")

    if is_plat("windows", "mingw") then
        add_syslinks("winmm", "urlmon", "shell32", "user32", "imm32", "pdh", "comdlg32", "gdi32")
    end

    on_load(function(package)
        if package:is_plat("macosx") then
            package:add("frameworks", "Cocoa", "IOKit", "CoreFoundation")
            package:add("syslinks", "objc")
        end
        if package:config("window_backend") == "glfw" then
            package:add("deps", "glfw")
        elseif package:config("window_backend") == "sdl2" then
            package:add("deps", "libsdl2")
        end
        if package:config("render_backend") == "opengl" then
            if package:is_plat("windows", "mingw") then
                package:add("syslinks", "opengl32")
            elseif package:is_plat("linux") then
                package:add("syslinks", "GL")
            elseif package:is_plat("macosx") then
                package:add("frameworks", "OpenGL")
            end
        elseif package:config("render_backend") == "vulkan" then
            package:add("deps", "vulkansdk", {system = true})
        end
        if not package:is_plat("windows", "mingw") then
            package:add("deps", "libcurl")
            package:add("syslinks", "pthread")
        end
        if package:is_plat("linux") and package:config("tray") then
            package:add("deps", "glib")
        end
        if package:config("app_runner") then
            package:add("links", "eui_app")
            package:add("defines", "EUI_APP_RUNNER=1")
        end
        package:add("links", "eui_neo")
        if package:config("render_backend") == "opengl" then
            package:add("links", "eui_glad")
        end
        if package:config("markdown") then
            package:add("links", "eui_md4c")
        end
    end)

    on_install("windows", "mingw", "linux", "macosx", function(package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        local configs = {}
        configs.window_backend = package:config("window_backend")
        configs.render_backend = package:config("render_backend")
        configs.app_runner     = package:config("app_runner")
        configs.markdown       = package:config("markdown")
        configs.tray           = package:config("tray")
        configs.vulkan_low_latency = package:config("vulkan_low_latency")
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
