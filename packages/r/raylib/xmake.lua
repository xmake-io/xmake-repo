package("raylib")

    set_homepage("http://www.raylib.com")
    set_description("A simple and easy-to-use library to enjoy videogames programming.")

    if is_plat("macosx") then
        add_urls("https://github.com/raysan5/raylib/releases/download/$(version)/raylib-$(version)-macOS.tar.gz")
        add_versions("2.5.0", "e9ebdf70ad4912dc9f3c7965dc702d5c61f2841aeae521e8dd3b0a96a9d82d58")
    else
        add_urls("https://github.com/raysan5/raylib/archive/$(version).tar.gz",
                 "https://github.com/raysan5/raylib.git")
        add_versions("2.5.0", "fa947329975bdc9ea284019f0edc30ca929535dc78dcf8c19676900d67a845ac")
    end

    if not is_plat("macosx") then
        add_deps("cmake >=3.11")
    end

    if is_plat("macosx") then
        add_frameworks("OpenGL", "CoreVideo", "CoreGraphics", "AppKit", "IOKit", "CoreFoundation", "Foundation")
    elseif is_plat("windows") then
        add_syslinks("gdi32", "user32", "winmm", "shell32")
    end

    on_install("macosx", function (package)
        os.cp("include/raylib.h", package:installdir("include"))
        os.cp("lib/libraylib.a", package:installdir("lib"))
    end)

    on_install("windows", function (package)
        import("package.tools.cmake").install(package, {"-DBUILD_EXAMPLES=OFF", "-DBUILD_GAMES=OFF"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                InitWindow(100, 100, "hello world!");
                Camera camera = { 0 };
                UpdateCamera(&camera);
            }
        ]]}, {includes = {"raylib.h"}}))
    end)
