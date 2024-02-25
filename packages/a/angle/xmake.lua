package("angle")

    set_homepage("https://chromium.googlesource.com/angle/angle")
    set_description("ANGLE - Almost Native Graphics Layer Engine")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/google/angle/archive/refs/heads/chromium/$(version).zip")
    add_versions("6288", "0d3bcf5bfd9eecd2b1635a6220a18f52a27ae5823928d4b6b083c54c163f963b")

    add_resources(">=6288", "chromium_zlib", "https://github.com/xmake-mirror/chromium_zlib.git", "646b7f569718921d7d4b5b8e22572ff6c76f2596")

    add_deps("python 3.x", {kind = "binary"})
    add_deps("zlib")
    add_deps("opengl")
    if is_plat("windows") then
        add_links("libEGL", "libGLESv2", "libANGLE")
        add_syslinks("user32", "gdi32", "dxgi", "dxguid", "d3d9", "delayimp")
        add_ldflags("/DELAYLOAD:d3d9.dll")
    else
        if is_plat("macosx") then
            add_syslinks("objc")
            add_frameworks("CoreFoundation", "CoreGraphics", "IOKit", "Metal", "IOSurface", "QuartzCore", "Cocoa")
        end
        if is_plat("linux") then
            add_deps("libx11", "libxext", "libxi")
        end
        add_links("EGL", "GLESv2", "ANGLE")
    end
    on_load("windows", "macosx", "linux", function (package)
        if not package:config("shared") then
            package:add("defines", "KHRONOS_STATIC")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local zlib_dir = package:resourcefile("chromium_zlib")
        os.cp(path.join(zlib_dir, "google"), "third_party/zlib")
        os.cp(path.join(os.scriptdir(), "port", package:version_str(), "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <EGL/egl.h>
            void test() {
                const char *extensionString =
                    static_cast<const char *>(eglQueryString(EGL_NO_DISPLAY, EGL_EXTENSIONS));
                EGLint res = eglGetError();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
