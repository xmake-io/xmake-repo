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
option("tray", {default = false, description = "Enable the system tray backend."})
option("vulkan_low_latency", {default = false, description = "Prefer low-latency Vulkan presentation when available."})

function eui_discover_macos_vulkan_sdk()
    if not is_plat("macosx") then
        return
    end
    if (os.getenv("VULKAN_SDK") or "") ~= "" or (os.getenv("VK_SDK_PATH") or "") ~= "" then
        return
    end

    import("lib.detect.find_tool")
    local brew = find_tool("brew")
    if not brew then
        return
    end
    local prefix = try {function()
        return os.iorunv(brew.program, {"--prefix"}):trim()
    end}
    if not prefix or prefix == "" then
        return
    end

    local header = path.join(prefix, "include", "vulkan", "vulkan.h")
    local library = path.join(prefix, "lib", "libvulkan.dylib")
    if os.isfile(header) and os.isfile(library) then
        os.setenv("VULKAN_SDK", prefix)
        os.setenv("VK_SDK_PATH", prefix)
        print("Vulkan SDK: using Homebrew prefix %s", prefix)
    end
end

eui_discover_macos_vulkan_sdk()

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
local build_modules = get_config("modules") and true or false
local enable_markdown = get_config("markdown") and true or false
local enable_tray = get_config("tray") and true or false
local vk_low_latency  = get_config("vulkan_low_latency") and true or false
local configured_platform = get_config("plat")
local target_is_windows = is_plat("windows") or is_plat("mingw")
    or configured_platform == "windows" or configured_platform == "mingw"
    or (not configured_platform and os.host() == "windows")
local target_is_linux = is_plat("linux") or configured_platform == "linux"
    or (not configured_platform and os.host() == "linux")
local target_is_macos = is_plat("macosx") or configured_platform == "macosx"
    or (not configured_platform and os.host() == "macosx")

print("EUI render backend: requested=%s, resolved=%s", get_config("render_backend") or "opengl", render_backend)
print("EUI window backend: %s", window_backend)

if window_backend == "sdl2" then
    add_requires("libsdl2", {configs = {shared = false}})
end
if render_backend == "vulkan" then
    add_requires("vulkansdk", {system = true})
end
if not target_is_windows then
    add_requires("libcurl", {configs = {shared = false}})
end

target("eui_zlib")
    set_kind("static")
    add_files("3rd/zlib-1.3.1/adler32.c", "3rd/zlib-1.3.1/compress.c", "3rd/zlib-1.3.1/crc32.c", "3rd/zlib-1.3.1/deflate.c", "3rd/zlib-1.3.1/gzclose.c", "3rd/zlib-1.3.1/gzlib.c", "3rd/zlib-1.3.1/gzread.c", "3rd/zlib-1.3.1/gzwrite.c", "3rd/zlib-1.3.1/inflate.c", "3rd/zlib-1.3.1/infback.c", "3rd/zlib-1.3.1/inffast.c", "3rd/zlib-1.3.1/inftrees.c", "3rd/zlib-1.3.1/trees.c", "3rd/zlib-1.3.1/uncompr.c", "3rd/zlib-1.3.1/zutil.c", {sourcekind = "cc"})
    add_includedirs("3rd/zlib-1.3.1", {public = true})
    if not target_is_windows then add_defines("HAVE_UNISTD_H") else add_defines("_CRT_SECURE_NO_WARNINGS") end
target_end()

target("eui_libpng")
    set_kind("static")
    add_files("3rd/libpng-1.6.43/png.c", "3rd/libpng-1.6.43/pngerror.c", "3rd/libpng-1.6.43/pngget.c", "3rd/libpng-1.6.43/pngmem.c", "3rd/libpng-1.6.43/pngpread.c", "3rd/libpng-1.6.43/pngread.c", "3rd/libpng-1.6.43/pngrio.c", "3rd/libpng-1.6.43/pngrtran.c", "3rd/libpng-1.6.43/pngrutil.c", "3rd/libpng-1.6.43/pngset.c", "3rd/libpng-1.6.43/pngtrans.c", "3rd/libpng-1.6.43/pngwio.c", "3rd/libpng-1.6.43/pngwrite.c", "3rd/libpng-1.6.43/pngwtran.c", "3rd/libpng-1.6.43/pngwutil.c", {sourcekind = "cc"})
    add_includedirs("3rd/libpng-1.6.43", "3rd/libpng-1.6.43/scripts", {public = true})
    add_deps("eui_zlib", {public = true})
    if is_arch("arm64", "aarch64") then
        add_files(
            "3rd/libpng-1.6.43/arm/arm_init.c",
            "3rd/libpng-1.6.43/arm/filter_neon_intrinsics.c",
            "3rd/libpng-1.6.43/arm/palette_neon_intrinsics.c",
            {sourcekind = "cc"}
        )
    end
    on_load(function(target)
        local generated_header = path.join(target:autogendir(), "pnglibconf.h")
        os.mkdir(path.directory(generated_header))
        os.cp("3rd/libpng-1.6.43/scripts/pnglibconf.h.prebuilt", generated_header)
        target:add("includedirs", target:autogendir(), {public = true})
    end)
target_end()

target("eui_freetype")
    set_kind("static")
    add_files("3rd/freetype/src/autofit/autofit.c", "3rd/freetype/src/base/ftbase.c", "3rd/freetype/src/base/ftbbox.c", "3rd/freetype/src/base/ftbdf.c", "3rd/freetype/src/base/ftbitmap.c", "3rd/freetype/src/base/ftcid.c", "3rd/freetype/src/base/ftfstype.c", "3rd/freetype/src/base/ftgasp.c", "3rd/freetype/src/base/ftglyph.c", "3rd/freetype/src/base/ftgxval.c", "3rd/freetype/src/base/ftinit.c", "3rd/freetype/src/base/ftmm.c", "3rd/freetype/src/base/ftotval.c", "3rd/freetype/src/base/ftpatent.c", "3rd/freetype/src/base/ftpfr.c", "3rd/freetype/src/base/ftstroke.c", "3rd/freetype/src/base/ftsynth.c", "3rd/freetype/src/base/fttype1.c", "3rd/freetype/src/base/ftwinfnt.c", "3rd/freetype/src/bdf/bdf.c", "3rd/freetype/src/bzip2/ftbzip2.c", "3rd/freetype/src/cache/ftcache.c", "3rd/freetype/src/cff/cff.c", "3rd/freetype/src/cid/type1cid.c", "3rd/freetype/src/gzip/ftgzip.c", "3rd/freetype/src/lzw/ftlzw.c", "3rd/freetype/src/pcf/pcf.c", "3rd/freetype/src/pfr/pfr.c", "3rd/freetype/src/psaux/psaux.c", "3rd/freetype/src/pshinter/pshinter.c", "3rd/freetype/src/psnames/psnames.c", "3rd/freetype/src/raster/raster.c", "3rd/freetype/src/sdf/sdf.c", "3rd/freetype/src/sfnt/sfnt.c", "3rd/freetype/src/smooth/smooth.c", "3rd/freetype/src/svg/svg.c", "3rd/freetype/src/truetype/truetype.c", "3rd/freetype/src/type1/type1.c", "3rd/freetype/src/type42/type42.c", "3rd/freetype/src/winfonts/winfnt.c", {sourcekind = "cc"})
    if target_is_windows then
        add_files("3rd/freetype/builds/windows/ftsystem.c", "3rd/freetype/builds/windows/ftdebug.c", {sourcekind = "cc"})
    elseif target_is_linux or target_is_macos then
        add_files("3rd/freetype/builds/unix/ftsystem.c", "3rd/freetype/src/base/ftdebug.c", {sourcekind = "cc"})
        add_defines("HAVE_UNISTD_H", "HAVE_FCNTL_H")
    else
        add_files("3rd/freetype/src/base/ftsystem.c", "3rd/freetype/src/base/ftdebug.c", {sourcekind = "cc"})
    end
    add_includedirs("3rd/freetype/include", {public = true})
    add_includedirs("3rd/libpng-1.6.43", "3rd/libpng-1.6.43/scripts")
    add_defines("FT2_BUILD_LIBRARY", "FT_CONFIG_OPTION_USE_PNG")
    add_deps("eui_libpng", {public = true})
target_end()

if window_backend == "glfw" then
    target("eui_glfw")
        set_kind("static")
        add_files("3rd/glfw/src/context.c", "3rd/glfw/src/init.c", "3rd/glfw/src/input.c", "3rd/glfw/src/monitor.c", "3rd/glfw/src/platform.c", "3rd/glfw/src/vulkan.c", "3rd/glfw/src/window.c", "3rd/glfw/src/egl_context.c", "3rd/glfw/src/osmesa_context.c", "3rd/glfw/src/null_init.c", "3rd/glfw/src/null_monitor.c", "3rd/glfw/src/null_window.c", "3rd/glfw/src/null_joystick.c", {sourcekind = "cc"})
        add_includedirs("3rd/glfw/include", {public = true})
        add_includedirs("3rd/glfw/src")
        if target_is_windows then
            add_files("3rd/glfw/src/win32_module.c", "3rd/glfw/src/win32_time.c", "3rd/glfw/src/win32_thread.c", "3rd/glfw/src/win32_init.c", "3rd/glfw/src/win32_joystick.c", "3rd/glfw/src/win32_monitor.c", "3rd/glfw/src/win32_window.c", "3rd/glfw/src/wgl_context.c", {sourcekind = "cc"})
            add_defines("_GLFW_WIN32", "UNICODE", "_UNICODE")
            add_syslinks("gdi32", {public = true})
            if is_plat("mingw") or configured_platform == "mingw" then
                add_defines("WINVER=0x0501")
                add_includedirs("3rd/glfw/deps/mingw")
            end
        elseif target_is_macos then
            add_files("3rd/glfw/src/posix_module.c", "3rd/glfw/src/cocoa_time.c", "3rd/glfw/src/posix_thread.c", {sourcekind = "cc"})
            add_files("3rd/glfw/src/cocoa_init.m", "3rd/glfw/src/cocoa_joystick.m", "3rd/glfw/src/cocoa_monitor.m", "3rd/glfw/src/cocoa_window.m", "3rd/glfw/src/nsgl_context.m", {sourcekind = "mm"})
            add_defines("_GLFW_COCOA")
            add_mflags("-fno-objc-arc")
            add_frameworks("Cocoa", "IOKit", "CoreFoundation", {public = true})
        elseif target_is_linux then
            add_files("3rd/glfw/src/posix_module.c", "3rd/glfw/src/posix_time.c", "3rd/glfw/src/posix_thread.c", "3rd/glfw/src/posix_poll.c", "3rd/glfw/src/linux_joystick.c", "3rd/glfw/src/x11_init.c", "3rd/glfw/src/x11_monitor.c", "3rd/glfw/src/x11_window.c", "3rd/glfw/src/xkb_unicode.c", "3rd/glfw/src/glx_context.c", {sourcekind = "cc"})
            add_defines("_GLFW_X11", "_DEFAULT_SOURCE")
            add_syslinks("X11", "Xrandr", "Xinerama", "Xi", "Xcursor", "Xext", "dl", "m", "rt", {public = true})
        end
    target_end()
end

if render_backend == "opengl" then
    target("eui_glad")
        set_kind("static")
        add_files("3rd/glad/src/glad.c", {sourcekind = "cc"})
        add_includedirs("3rd/glad/include", {public = true})
    target_end()
end

if enable_markdown then
    target("eui_md4c")
        set_kind("static")
        add_files("3rd/md4c/src/md4c.c", {sourcekind = "cc"})
        add_includedirs("3rd/md4c/src", {public = true})
    target_end()
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

    -- GCC/MinGW already treats .c files as C.  Do not pass MSVC's /TC
    -- switch when the target platform is Windows with a MinGW toolchain.
    local c_flags = {}

    local bridge_flags = table.copy(c_flags)
    if is_plat("macosx") then
        table.insert(bridge_flags, "-x")
        table.insert(bridge_flags, "objective-c")
    end

    add_files("3rd/yyjson-0.12.0/src/yyjson.c", {sourcekind = "cc", force = {cxflags = c_flags}})
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

    on_load(function (target)
        if not is_plat("linux") or not enable_tray then
            return
        end
        import("package.manager.find_package")
        local function apply(result, define)
            target:add("defines", define, {public = true})
            if result.includedirs then target:add("includedirs", result.includedirs, {public = true}) end
            if result.linkdirs then target:add("linkdirs", result.linkdirs, {public = true}) end
            if result.links then target:add("links", result.links, {public = true}) end
        end
        local gio = find_package("pkgconfig::gio-2.0")
        if gio then
            apply(gio, "EUI_TRAY_SNI=1")
            return
        end
        local appindicator = find_package("pkgconfig::appindicator3-0.1")
        if appindicator then
            apply(appindicator, "EUI_TRAY_APPINDICATOR=1")
            return
        end
        os.raise("Linux tray support requires glib/gio (gio-2.0, preferred, SNI backend) " ..
                 "or GTK3 + libappindicator (legacy fallback), detected via pkg-config, " ..
                 "but none of them were found. Install your distribution's glib2 development " ..
                 "package, or configure with --tray=n to build without tray support.")
    end)

    if enable_markdown then
        add_defines("EUI_HAS_MD4C=1", {public = true})
        add_deps("eui_md4c")
    end

    add_deps("eui_freetype", {public = true})
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
        add_packages("vulkansdk", {public = true})
    end
    if window_backend == "glfw" then
        add_deps("eui_glfw", {public = true})
    elseif window_backend == "sdl2" then
        add_packages("libsdl2", {public = true})
    end
    add_packages("libcurl", {public = true, optional = true})
    if not target_is_windows and has_package("libcurl") then
        add_defines("EUI_HAS_CURL=1", {public = true})
    end

    if not target_is_windows then
        add_syslinks("pthread", {public = true})
    end

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

    if not is_mode("debug") then
        add_cxxflags("-Os", "-fno-exceptions", "-fno-rtti")
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
        add_includedirs("include", ".")
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
            if not is_mode("debug") then
                add_cxxflags("-Os", "-fno-exceptions", "-fno-rtti")
            end
        target_end()
    end
end
