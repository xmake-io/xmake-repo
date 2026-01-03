package("fls-float-raylib")
    set_homepage("http://www.raylib.com")
    set_description("Custom raylib build for FloatEngine.")
    set_license("zlib")

    add_urls("https://github.com/Fls-Float/raylib.git")
    add_versions("2025.12.05", "a09bfe564357a25da0265616feed37cd5a30caa4")

    if not (is_plat("macosx") and is_arch("x86_64")) then
        add_deps("cmake >=3.11")
    end

    if is_plat("macosx") then
        add_frameworks("CoreVideo", "CoreGraphics", "AppKit", "IOKit", "CoreFoundation", "Foundation")
    elseif is_plat("windows", "mingw") then
        add_syslinks("gdi32", "user32", "winmm", "shell32")
    elseif is_plat("linux") then
        add_syslinks("pthread", "dl", "m")
        add_deps("libx11", "libxrandr", "libxrender", "libxinerama", "libxcursor", "libxi", "libxfixes", "libxext")
    elseif is_plat("android") then
        add_syslinks("log", "android", "EGL", "GLESv2", "OpenSLES", "m")
    end
    add_deps("opengl", {optional = true})

    on_install("windows", "mingw", function (package)
        local configs = {"-DBUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("wasm") then
            table.insert(configs, "-DPLATFORM=Web")
        elseif package:is_plat("android") then
            table.insert(configs, "-DPLATFORM=Android")
            table.insert(configs, "-DANDROID_ABI=" .. (package:arch() or "arm64-v8a"))
            table.insert(configs, "-DOPENGL_API=ES2")
            table.insert(configs, "-DUSE_EXTERNAL_GLFW=OFF")
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = {"libx11", "libxrender", "libxrandr", "libxinerama", "libxcursor", "libxi", "libxfixes", "libxext"}})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                Image image = rlLoadImage("image.png");
            }
        ]]}, {includes = {"raylib.h"}, configs = {languages = "cxx11"}}))
    end)
