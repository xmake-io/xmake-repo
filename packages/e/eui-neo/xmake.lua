package("eui-neo")
    set_homepage("https://github.com/sudoevolve/EUI-NEO")
    set_description("Cross-platform, high-performance, low-overhead C++17 GPUI framework")
    set_license("Apache-2.0")

    add_urls("https://github.com/sudoevolve/EUI-NEO/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sudoevolve/EUI-NEO.git")

    add_versions("v0.5.5", "cf0da91d7544fe406b704922137fd4d55ed080b3e647501e0ca5303abb00eb98")

    add_configs("window_backend", {description = "Window backend", default = "glfw", values = {"glfw", "sdl2"}})
    add_configs("render_backend", {description = "Render backend", default = "opengl", values = {"auto", "opengl", "vulkan"}})
    add_configs("markdown", {description = "Enable MD4C Markdown parsing support", default = true, type = "boolean"})
    add_configs("vulkan_low_latency", {description = "Prefer low-latency Vulkan presentation", default = false, type = "boolean"})

    add_deps("cmake")
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
        if not package:is_plat("windows", "mingw") then
            package:add("deps", "curl")
        end
    end)

    on_install(function(package)
        local configs = {}
        table.insert(configs, "-DEUI_VULKAN_LOW_LATENCY_PRESENT=" .. (package:config("vulkan_low_latency") and "ON" or "OFF"))
        table.insert(configs, "-DEUI_RENDER_BACKEND=" .. package:config("render_backend"))
        table.insert(configs, "-DEUI_WINDOW_BACKEND=" .. package:config("window_backend"))
        table.insert(configs, "-DEUI_ENABLE_MARKDOWN=" .. (package:config("markdown") and "ON" or "OFF"))
        table.insert(configs, "-DEUI_BUILD_APPS=OFF")
        table.insert(configs, "-DEUI_BUILD_USER_APPS=OFF")
        table.insert(configs, "-DEUI_ENABLE_INSTALL=ON")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DEUI_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                eui::Ui ui;
                ui.stack("root");
            }
        ]]}, {configs = {languages = "c++17"}, includes = "eui_neo.h"}))
    end)
