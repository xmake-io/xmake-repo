set_project("EUI-NEO")
set_version("0.5.5")
set_xmakever("2.9.0")
set_languages("c99", "cxx17")

option("window_backend", {default = "glfw", values = {"glfw", "sdl2"}, description = "Window backend: glfw or sdl2"})
option("render_backend", {default = "opengl", values = {"auto", "opengl", "vulkan"}, description = "Render backend: auto, opengl, or vulkan"})
option("shared", {default = false, description = "Build eui_neo as a shared library instead of a static library."})
option("apps", {default = true, description = "Build bundled EUI-NEO example applications."})
option("user_apps", {default = true, description = "Build user applications from apps/."})
option("modules", {default = true, description = "Build optional EUI-NEO modules when their directories are present."})
option("markdown", {default = true, description = "Enable MD4C Markdown parsing support."})
option("vulkan_low_latency", {default = false, description = "Prefer low-latency Vulkan presentation when available."})
-- =============================================================================
-- Resolve backends
-- =============================================================================

local render_backend = get_config("render_backend") or "opengl"
if render_backend == "auto" then
    if find_package("vulkan") then
        render_backend = "vulkan"
    else
        render_backend = "opengl"
        print("Vulkan SDK not found; falling back to OpenGL.")
    end
end

local window_backend = get_config("window_backend") or "glfw"
local build_shared  = get_config("shared") and true or false
local build_apps    = get_config("apps") and true or false
local build_user    = get_config("user_apps") and true or false
local build_modules = get_config("modules") and true or false
local enable_markdown = get_config("markdown") and true or false
local vk_low_latency  = get_config("vulkan_low_latency") and true or false

print("EUI render backend: requested=%s, resolved=%s", get_config("render_backend") or "opengl", render_backend)
print("EUI window backend: %s", window_backend)

local app_main_source
if window_backend == "sdl2" then
    app_main_source = "core/app/sdl2_app_main.cpp"
else
    app_main_source = "core/app/glfw_app_main.cpp"
end

-- =============================================================================
-- External dependencies (resolved through xrepo)
-- =============================================================================

add_requires("freetype", {configs = {png = true, zlib = true, bzip2 = false, harfbuzz = false, brotli = false}})
add_requires("libpng", "zlib")

if window_backend == "glfw" then
    add_requires("glfw", {configs = {shared = false}})
end
if window_backend == "sdl2" then
    add_requires("sdl2", {configs = {shared = false}})
end
if render_backend == "vulkan" then
    add_requires("vulkan")
end
if not is_plat("windows") then
    add_requires("libcurl", {configs = {shared = false}})
end
-- =============================================================================
-- Compile / link option helpers
-- =============================================================================

function eui_apply_compile_options(target)
    if is_plat("windows") then
        target:add("cxflags", "/utf-8")
        if not is_mode("debug") then
            target:add("cxflags", "/O1", "/GS-", "/sdl-", "/wd4819")
        end
    else
        if not is_mode("debug") then
            target:add("cxxflags", "-Os", "-fno-exceptions", "-fno-rtti")
        end
    end
end

function eui_apply_app_link_options(target)
    if is_plat("windows") then
        target:add("ldflags", "/ENTRY:mainCRTStartup", "/SUBSYSTEM:WINDOWS")
        if not is_mode("debug") then
            target:add("ldflags", "/OPT:REF", "/OPT:ICF", "/INCREMENTAL:NO")
        end
    elseif is_plat("macosx") then
        if not is_mode("debug") then
            target:add("ldflags", "-Wl,-dead_strip")
        end
    else
        if not is_mode("debug") then
            target:add("ldflags", "-Wl,--gc-sections", "-s")
        end
    end
end

-- =============================================================================
-- Vendored single-file third-party libraries (built directly from 3rd/)
-- =============================================================================

if render_backend == "opengl" then
    target("eui_glad")
        set_kind("static")
        add_files("3rd/glad/src/glad.c",
            {force = {cxflags = {is_plat("windows") and "/TC" or ""}}})
        add_includedirs("3rd/glad/include", {public = true})
    target_end()
end

if enable_markdown then
    target("eui_md4c")
        set_kind("static")
        add_files("3rd/md4c/src/md4c.c",
            {force = {cxflags = {is_plat("windows") and "/TC" or ""}}})
        add_includedirs("3rd/md4c/src", {public = true})
    target_end()
end
-- =============================================================================
-- Core library: eui_neo
-- =============================================================================

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
        "core/render/image_facade.cpp",
        "core/render/image_source.cpp",
        "core/render/primitive.cpp",
        "core/render/render_backend.cpp",
        "core/render/shadertoy.cpp",
        "core/render/shadertoy_json.cpp",
        "core/render/shadertoy_primitive.cpp",
        "core/render/stb_image_impl.cpp",
        "core/render/text.cpp",
        "core/window/window_backend.cpp"
    )

    -- C files: force /TC on MSVC so they compile as C, not C++.
    local c_flags = {}
    if is_plat("windows") then
        table.insert(c_flags, "/TC")
    end

    -- The native bridge files contain Objective-C (Cocoa/AppKit) code on
    -- macOS, so compile them with the ObjC frontend there, mirroring
    -- upstream CMake's LANGUAGE OBJC source property.
    local bridge_flags = table.copy(c_flags)
    if is_plat("macosx") then
        table.insert(bridge_flags, "-x")
        table.insert(bridge_flags, "objective-c")
    end

    add_files("3rd/yyjson-0.12.0/src/yyjson.c", {force = {cxflags = c_flags}})
    add_files("core/platform/native_bridge.c", "core/platform/tray_bridge.c",
        {force = {cxflags = bridge_flags}})

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
            {force = {cxflags = bridge_flags}})
    end

    add_includedirs("include", ".", "3rd/tray", {public = true})
    add_includedirs("3rd/yyjson-0.12.0/src")
    add_includedirs("3rd")

    add_defines("YYJSON_DISABLE_WRITER=1")
    if render_backend == "opengl" then
        add_defines("EUI_RENDER_BACKEND_OPENGL=1", {public = true})
    elseif render_backend == "vulkan" then
        add_defines("EUI_RENDER_BACKEND_VULKAN=1", {public = true})
        if vk_low_latency then
            add_defines("EUI_VULKAN_LOW_LATENCY_PRESENT=1")
        end
    end
    if window_backend == "sdl2" then
        add_defines("EUI_WINDOW_BACKEND_SDL2=1", {public = true})
    end

    if is_plat("windows") then
        add_defines("EUI_TRAY_WINAPI=1", "NOMINMAX", {public = true})
        add_syslinks("winmm", "urlmon", "shell32", "user32", "imm32", "pdh", "comdlg32", {public = true})
    elseif is_plat("macosx") then
        add_defines("EUI_TRAY_APPKIT=1", {public = true})
        add_frameworks("Cocoa", {public = true})
        add_syslinks("objc", {public = true})
    end

    if enable_markdown then
        add_defines("EUI_HAS_MD4C=1", {public = true})
        add_deps("eui_md4c")
    end

    add_packages("freetype", "libpng", "zlib", {public = true})
    if render_backend == "opengl" then
        add_deps("eui_glad")
        if is_plat("windows") then
            add_syslinks("opengl32", {public = true})
        elseif is_plat("linux") then
            add_syslinks("GL", {public = true})
        elseif is_plat("macosx") then
            add_frameworks("OpenGL", {public = true})
        end
    elseif render_backend == "vulkan" then
        add_packages("vulkan", {public = true})
    end
    if window_backend == "glfw" then
        add_packages("glfw", {public = true})
    elseif window_backend == "sdl2" then
        add_packages("sdl2", {public = true})
    end
    add_packages("libcurl", {public = true, optional = true})
    if not is_plat("windows", "mingw") and has_package("libcurl") then
        add_defines("EUI_HAS_CURL=1", {public = true})
    end

    if not is_plat("windows", "mingw") then
        add_syslinks("pthread", {public = true})
    end

    -- Install rules (for `xmake install` and xrepo packaging)
    add_installfiles("include/(**)", {prefixdir = "include"})
    add_installfiles("components/(**.h)", {prefixdir = "include/components"})
    add_installfiles("core/(**.h)", {prefixdir = "include/core"})
    add_installfiles("3rd/stb_image.h", "3rd/nanosvg.h", "3rd/nanosvgrast.h", {prefixdir = "include/3rd"})
    add_installfiles("3rd/tray/tray.h", {prefixdir = "include/3rd/tray"})
    if render_backend == "opengl" then
        add_installfiles("3rd/glad/include/(**.h)", {prefixdir = "include"})
    end
    if enable_markdown then
        add_installfiles("3rd/md4c/src/md4c.h", {prefixdir = "include"})
    end

    if is_plat("windows") then
        add_cxflags("/utf-8")
        if not is_mode("debug") then
            add_cxflags("/O1", "/GS-", "/sdl-", "/wd4819")
        end
    else
        if not is_mode("debug") then
            add_cxxflags("-Os", "-fno-exceptions", "-fno-rtti")
        end
    end
target_end()
-- =============================================================================
-- Optional modules
-- =============================================================================

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
                add_cxflags("/utf-8")
                if not is_mode("debug") then
                    add_cxflags("/O1", "/GS-", "/sdl-", "/wd4819")
                end
            else
                if not is_mode("debug") then
                    add_cxxflags("-Os", "-fno-exceptions", "-fno-rtti")
                end
            end
        target_end()
    end
end
-- =============================================================================
-- App rule: link eui_neo, apply app link/compile options, copy assets.
-- =============================================================================

rule("eui.app")
    on_config(function(target)
        target:add("deps", "eui_neo")
        target:add("packages", "freetype", "libpng", "zlib")
        if window_backend == "glfw" then
            target:add("packages", "glfw")
        else
            target:add("packages", "sdl2")
        end
        if render_backend == "vulkan" then
            target:add("packages", "vulkan")
        end
        -- Apply compile options (mirror of eui_apply_compile_options)
        if is_plat("windows") then
            target:add("cxflags", "/utf-8")
            if not is_mode("debug") then
                target:add("cxflags", "/O1", "/GS-", "/sdl-", "/wd4819")
            end
        else
            if not is_mode("debug") then
                target:add("cxxflags", "-Os", "-fno-exceptions", "-fno-rtti")
            end
        end
        -- Apply app link options (mirror of eui_apply_app_link_options)
        if is_plat("windows") then
            target:add("ldflags", "/ENTRY:mainCRTStartup", "/SUBSYSTEM:WINDOWS", {force = true})
            if not is_mode("debug") then
                target:add("ldflags", "/OPT:REF", "/OPT:ICF", "/INCREMENTAL:NO", {force = true})
            end
        elseif is_plat("macosx") then
            if not is_mode("debug") then
                target:add("ldflags", "-Wl,-dead_strip", {force = true})
            end
        else
            if not is_mode("debug") then
                target:add("ldflags", "-Wl,--gc-sections", "-s", {force = true})
            end
        end
    end)
    after_build(function(target)
        local assets_dir = path.join(os.projectdir(), "assets")
        if os.exists(assets_dir) then
            local dest = path.join(target:targetdir(), "assets")
            os.tryrm(dest)
            os.cp(assets_dir, dest)
        end
    end)
rule_end()

-- =============================================================================
-- Bundled example applications (examples/*.cpp)
-- =============================================================================

if build_apps then
    for _, file in ipairs(os.files("examples/*.cpp")) do
        local name = path.basename(file)
        if name == "keyboard" and not (build_modules and os.exists("modules/keyboard/keyboard.h")) then
            print("Skipping keyboard example (module not available).")
            goto continue
        end
        target(name)
            set_kind("binary")
            set_group("examples")
            add_files(app_main_source, file)
            add_rules("eui.app")
            add_includedirs("include", ".")
            if name == "serial_tool" and build_modules and os.exists("modules/serial/serial.h") then
                add_deps("eui_module_serial")
            end
            -- Shadertoy preset asset paths
            if name == "shadertoy" then
                add_defines(
                    "EUI_SHADERTOY_DEMO_SOURCE=\"assets/shaders/shadertoy/demo.frag\"",
                    "EUI_SHADERTOY_DEMO_SPIRV=\"assets/shaders/shadertoy/demo.frag.spv\"",
                    "EUI_SHADERTOY_PRESETS_DIR=\"assets/shaders/shadertoy\"",
                    "EUI_SHADERTOY_PRESET_SPIRV_DIR=\"assets/shaders/shadertoy\""
                )
            end
            if name == "gallery" then
                add_defines(
                    "EUI_GALLERY_SHADERTOY_SOURCE=\"assets/shaders/shadertoy/demo.frag\"",
                    "EUI_GALLERY_SHADERTOY_NOISE=\"assets/shaders/shadertoy/blackhole/color_noise.png\"",
                    "EUI_GALLERY_SHADERTOY_SPIRV=\"assets/shaders/shadertoy/gallery_demo.frag.spv\""
                )
            end
        target_end()
        ::continue::
    end
end
-- =============================================================================
-- User applications (apps/*.cpp and apps/<name>/app.cpp)
-- =============================================================================

if build_user then
    for _, file in ipairs(os.files("apps/*.cpp")) do
        local name = path.basename(file)
        target(name)
            set_kind("binary")
            set_group("apps")
            add_files(app_main_source, file)
            add_rules("eui.app")
            add_includedirs("include", ".")
        target_end()
    end

    for _, dir in ipairs(os.dirs("apps/*")) do
        local appfile = path.join(dir, "app.cpp")
        if os.exists(appfile) then
            local name = path.basename(dir)
            target(name)
                set_kind("binary")
                set_group("apps")
                add_files(app_main_source, appfile)
                add_rules("eui.app")
                add_includedirs("include", ".", dir)
                after_build(function(target)
                    local app_assets = path.join(os.projectdir(), dir, "assets")
                    if os.exists(app_assets) then
                        os.cp(app_assets, path.join(target:targetdir(), "assets"))
                    end
                end)
            target_end()
        end
    end
end
