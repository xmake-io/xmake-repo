set_project("EUI-NEO")
set_version("0.5.8")
set_xmakever("2.9.0")
set_languages("c99", "cxx17")

option("window_backend", {default = "glfw", values = {"glfw", "sdl2"}, description = "Window backend: glfw or sdl2"})
option("render_backend", {default = "opengl", values = {"auto", "opengl", "vulkan"}, description = "Render backend: auto, opengl, or vulkan"})
option("app_runner", {default = false, description = "Build the EUI application runner (defines main)."})
option("shared", {default = false, description = "Build eui_neo as a shared library instead of a static library."})
option("modules", {default = true, description = "Build optional EUI-NEO modules when their directories are present."})
option("markdown", {default = true, description = "Enable MD4C Markdown parsing support."})
option("tray", {default = true, description = "Enable the system tray backend."})
option("vulkan_low_latency", {default = false, description = "Prefer low-latency Vulkan presentation when available."})

local render_backend = get_config("render_backend") or "opengl"
if render_backend == "auto" then
    if find_package("vulkansdk") or find_package("vulkan") then
        render_backend = "vulkan"
    else
        render_backend = "opengl"
    end
end

local window_backend = get_config("window_backend") or "glfw"
local build_shared  = get_config("shared") and true or false
local build_modules = get_config("modules") and true or false
local enable_markdown = get_config("markdown") and true or false
local enable_tray = get_config("tray") and true or false
local vk_low_latency  = get_config("vulkan_low_latency") and true or false

print("EUI render backend: requested=%s, resolved=%s", get_config("render_backend") or "opengl", render_backend)
print("EUI window backend: %s", window_backend)

add_requires("freetype", {configs = {png = true, zlib = true, bzip2 = false, harfbuzz = false, brotli = false}})
add_requires("libpng", "zlib", "yyjson")

if window_backend == "glfw" then
    add_requires("glfw", {configs = {shared = false}})
elseif window_backend == "sdl2" then
    add_requires("libsdl2", {configs = {shared = false}})
end
if render_backend == "opengl" then
    add_requires("glad v0.1.36")
elseif render_backend == "vulkan" then
    add_requires("vulkansdk", {system = true})
end
if not is_plat("windows", "mingw") then
    add_requires("libcurl", {configs = {shared = false}})
end
if is_plat("linux") and enable_tray then
    add_requires("glib")
end
if enable_markdown then
    add_requires("md4c")
end

target("eui_neo")
    set_kind(build_shared and "shared" or "static")
    set_group("framework")

    add_files(
        "core/platform/async.cpp",
        "core/platform/json.cpp",
        "core/platform/network.cpp",
        "core/platform/performance_stats.cpp",
        "core/platform/platform.cpp",
        "core/render/image.cpp",
        "core/render/image_stream.cpp",
        "core/render/image_facade.cpp",
        "core/render/image_source.cpp",
        "core/render/primitive.cpp",
        "core/render/render_backend.cpp",
        "core/render/shadertoy.cpp",
        "core/render/shadertoy_json.cpp",
        "core/render/shadertoy_primitive.cpp",
        "core/render/stb_image_impl.cpp",
        "core/render/text.cpp",
        "core/window/window_backend.cpp",
        "core/window/window_input_backend.cpp"
    )

    local bridge_flags = {}
    if is_plat("macosx") then
        table.insert(bridge_flags, "-x")
        table.insert(bridge_flags, "objective-c")
    end

    add_files("core/platform/native_bridge.c", "core/platform/tray_bridge.c",
        {sourcekind = "cc", force = {cxflags = bridge_flags}})

    if render_backend == "opengl" then
        add_files(
            "core/render/opengl/opengl_backend.cpp",
            "core/render/opengl/opengl_image.cpp",
            "core/render/opengl/opengl_primitives.cpp",
            "core/render/opengl/opengl_shadertoy.cpp",
            "core/render/opengl/opengl_text.cpp"
        )
    elseif render_backend == "vulkan" then
        add_files(
            "core/render/vulkan/vulkan_backend.cpp",
            "core/render/vulkan/vulkan_cache.cpp",
            "core/render/vulkan/vulkan_primitives.cpp",
            "core/render/vulkan/vulkan_polygon.cpp",
            "core/render/vulkan/vulkan_shadertoy.cpp",
            "core/render/vulkan/vulkan_text.cpp",
            "core/render/vulkan/vulkan_image.cpp"
        )
    end

    if window_backend == "glfw" then
        add_files("core/platform/ime_bridge.c",
            {sourcekind = "cc", force = {cxflags = bridge_flags}})
    end

    add_includedirs("include", ".", "3rd/tray", {public = true})
    add_includedirs("3rd")

    add_defines("YYJSON_DISABLE_WRITER=1")
    if render_backend == "opengl" then
        add_defines("EUI_RENDER_BACKEND_OPENGL=1", {public = true})
    elseif render_backend == "vulkan" then
        add_defines("EUI_RENDER_BACKEND_VULKAN=1", {public = true})
        if vk_low_latency then
            add_defines("EUI_VULKAN_LOW_LATENCY_PRESENT=1", {public = true})
        end
    end
    if window_backend == "sdl2" then
        add_defines("EUI_WINDOW_BACKEND_SDL2=1", {public = true})
    end

    if is_plat("windows", "mingw") then
        add_defines("EUI_TRAY_WINAPI=1", "NOMINMAX", {public = true})
        add_syslinks("winmm", "urlmon", "shell32", "user32", "imm32", "pdh", "comdlg32", {public = true})
    elseif is_plat("macosx") then
        add_defines("EUI_TRAY_APPKIT=1", {public = true})
        add_frameworks("Cocoa", {public = true})
        add_syslinks("objc", {public = true})
    elseif is_plat("linux") and enable_tray then
        add_defines("EUI_TRAY_SNI=1", {public = true})
        add_packages("glib", {public = true})
    end

    if enable_markdown then
        add_defines("EUI_HAS_MD4C=1", {public = true})
        add_packages("md4c", {public = true})
    end

    add_packages("freetype", "libpng", "zlib", "yyjson", {public = true})
    if render_backend == "opengl" then
        add_packages("glad", {public = true})
        if is_plat("windows", "mingw") then
            add_syslinks("opengl32", {public = true})
        elseif is_plat("linux") then
            add_syslinks("GL", {public = true})
        elseif is_plat("macosx") then
            add_frameworks("OpenGL", {public = true})
        end
    elseif render_backend == "vulkan" then
        add_packages("vulkansdk", {public = true})
    end
    if window_backend == "glfw" then
        add_packages("glfw", {public = true})
    elseif window_backend == "sdl2" then
        add_packages("libsdl2", {public = true})
    end
    add_packages("libcurl", {public = true, optional = true})
    if not is_plat("windows", "mingw") and has_package("libcurl") then
        add_defines("EUI_HAS_CURL=1", {public = true})
    end

    if not is_plat("windows", "mingw") then
        add_syslinks("pthread", {public = true})
    end

    add_installfiles("include/(**)", {prefixdir = "include"})
    add_installfiles("components/(**.h)", {prefixdir = "include/components"})
    add_installfiles("core/(**.h)", {prefixdir = "include/core"})
    add_installfiles("3rd/stb_image.h", "3rd/nanosvg.h", "3rd/nanosvgrast.h", {prefixdir = "include/3rd"})
    add_installfiles("3rd/tray/tray.h", {prefixdir = "include/3rd/tray"})
        if is_plat("windows") then
        add_cxflags("/utf-8", {tools = {"cl", "clang_cl"}})
        if not is_mode("debug") then
            add_cxflags("/O1", "/GS-", "/sdl-", "/wd4819", {tools = {"cl", "clang_cl"}})
        end
    else
        if not is_mode("debug") then
            add_cxxflags("-Os", "-fno-exceptions", "-fno-rtti")
        end
    end
target_end()

if get_config("app_runner") then
    local app_main_source
    if window_backend == "sdl2" then
        app_main_source = "core/app/sdl2_app_main.cpp"
    else
        app_main_source = "core/app/glfw_app_main.cpp"
    end

    target("eui_app")
        set_kind("static")
        set_group("framework")
        add_files(app_main_source)
        add_includedirs("include", ".", {public = true})
        add_deps("eui_neo", {public = true})
        add_defines("EUI_APP_RUNNER_LIBRARY=1")
    target_end()
end

if build_modules then
    if os.exists("modules/keyboard/keyboard.h") then
        target("eui_module_keyboard")
            set_kind("headeronly")
            set_group("modules")
            add_includedirs("modules/keyboard", {public = true})
            add_deps("eui_neo")
        target_end()
    end

    if os.exists("modules/media/media.h") then
        target("eui_module_media")
            set_kind("headeronly")
            set_group("modules")
            add_includedirs("modules/media", {public = true})
            add_deps("eui_neo")
        target_end()
    end

    if os.exists("modules/serial/serial.h") then
        target("eui_module_serial")
            set_kind("static")
            set_group("modules")
            add_files("modules/serial/serial.cpp")
            add_includedirs("modules/serial", {public = true})
            add_deps("eui_neo")
            if is_plat("windows") then
                add_cxflags("/utf-8", {tools = {"cl", "clang_cl"}})
                if not is_mode("debug") then
                    add_cxflags("/O1", "/GS-", "/sdl-", "/wd4819", {tools = {"cl", "clang_cl"}})
                end
            else
                if not is_mode("debug") then
                    add_cxxflags("-Os", "-fno-exceptions", "-fno-rtti")
                end
            end
        target_end()
    end
end
