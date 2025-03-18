package("screen_capture_lite")
    set_homepage("https://github.com/smasherprog/screen_capture_lite")
    set_description("cross platform screen/window capturing library")
    set_license("MIT")

    add_urls("https://github.com/smasherprog/screen_capture_lite/archive/refs/tags/$(version).tar.gz",
             "https://github.com/smasherprog/screen_capture_lite.git")

    add_versions("17.1.1368", "78b5f6c2689f49672ff465e4e832377a244455ada90d271d1cd44c3c3ecef952")

    add_deps("cmake", "lodepng", "tinyjpeg")

    if is_plat("windows") then
        add_syslinks("user32", "gdi32", "dwmapi", "d3d11", "dxgi")
    elseif is_plat("linux") then
        add_deps("libxtst", "libxinerama", "libx11", "libxfixes")
    elseif is_plat("macosx") then
        add_frameworks("Foundation", "CoreFoundation", "CoreGraphics", "CoreVideo", "CoreMedia", "ApplicationServices", "AVFoundation")
    end

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_EXAMPLE=OFF", "-DBUILD_CSHARP=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ScreenCapture.h>
            void test() {
                SL::Screen_Capture::CanRequestScreenCapture();
                SL::Screen_Capture::GetMonitors();
                SL::Screen_Capture::GetWindows();
            }
        ]]}, {configs = {languages = "cxx17"}}))
    end)
