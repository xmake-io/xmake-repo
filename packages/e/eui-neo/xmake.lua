-- xrepo package definition for EUI-NEO
-- https://github.com/sudoevolve/EUI-NEO
--
-- After submitting this to the xrepo-repo, users can do:
--   add_requires("eui-neo")
--   target("myapp")
--       add_packages("eui-neo")
--
-- Configurable options:
--   add_requires("eui-neo", {configs = {render_backend = "vulkan", window_backend = "glfw"}})
--   add_requires("eui-neo", {configs = {shared = true}})

package("eui-neo")
    set_homepage("https://github.com/sudoevolve/EUI-NEO")
    set_description("Cross-platform, high-performance, low-overhead C++17 GPUI framework")
    set_license("Apache-2.0")

    set_urls("https://github.com/lilyco-42/EUI-NEO.git")

    add_versions("v0.5.5", "df2399495a139a21290bf8a9288f5efba2c52bde")

    -- Build configuration options (mirror the xmake.lua options)
    add_configs("window_backend", {description = "Window backend", default = "glfw", values = {"glfw", "sdl2"}})
    add_configs("render_backend", {description = "Render backend", default = "opengl", values = {"auto", "opengl", "vulkan"}})
    add_configs("shared", {description = "Build eui_neo as a shared library", default = false, type = "boolean"})
    add_configs("markdown", {description = "Enable MD4C Markdown parsing support", default = true, type = "boolean"})
    add_configs("vulkan_low_latency", {description = "Prefer low-latency Vulkan presentation", default = false, type = "boolean"})

    -- External dependencies resolved by xrepo
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
        -- Build EUI-NEO using its own xmake.lua
        local configs = {}
        configs.window_backend = package:config("window_backend")
        configs.render_backend = package:config("render_backend")
        configs.shared = package:config("shared")
        configs.markdown = package:config("markdown")
        configs.vulkan_low_latency = package:config("vulkan_low_latency")
        -- Only build the core library (skip examples/user apps/modules)
        configs.apps = false
        configs.user_apps = false
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function(package)
        assert(os.isfile(path.join(package:installdir(), "lib", "eui_neo.lib"))
            or os.isfile(path.join(package:installdir(), "lib", "libeui_neo.a"))
            or os.isfile(path.join(package:installdir(), "lib", "libeui_neo.so")))
    end)
package_end()
