package("raylib")

    set_homepage("http://www.raylib.com")
    set_description("A simple and easy-to-use library to enjoy videogames programming.")

    if is_plat("macosx") and is_arch("x86_64") then
        add_urls("https://github.com/raysan5/raylib/releases/download/$(version).tar.gz", {version = function (version)
            if version:ge("3.5.0") then
                return version .. "/raylib-" .. version .. "_macos"
            else
                return version .. "/raylib-" .. version .. "-macOS"
            end
        end})
        add_versions("2.5.0", "e9ebdf70ad4912dc9f3c7965dc702d5c61f2841aeae521e8dd3b0a96a9d82d58")
        add_versions("3.0.0", "8244898b09887f29baa9325b5ae47c30ec0f45dc15b4f740178c65af068b3141")
        add_versions("3.5.0", "9b9be75fe1b231225c91a6fcf5ed9c24cbf03c6193f917e40e4655ef27f281e2")
        add_versions("3.7.0", "439dc1851dd1b7f385f4caf4f5c7191dda90add9d8d531e5e74702315e432003")
        add_versions("4.0.0", "be73734815a7ef4eb3130f4a2ecaabb2059602745ae6ce1173201a74034c2ec9")
        add_versions("4.2.0", "5f79c103b82c577698b01c7b2c166d0c2b51615886b7fabdc671199f0aaf4b38")
    else
        add_urls("https://github.com/raysan5/raylib/archive/$(version).tar.gz",
                 "https://github.com/raysan5/raylib.git")
        add_versions("2.5.0", "fa947329975bdc9ea284019f0edc30ca929535dc78dcf8c19676900d67a845ac")
        add_versions("3.0.0", "164d1cc1710bb8e711a495e84cc585681b30098948d67d482e11dc37d2054eab")
        add_versions("3.5.0", "761985876092fa98a99cbf1fef7ca80c3ee0365fb6a107ab901a272178ba69f5")
        add_versions("3.7.0", "7bfdf2e22f067f16dec62b9d1530186ddba63ec49dbd0ae6a8461b0367c23951")
        add_versions("4.0.0", "11f6087dc7bedf9efb3f69c0c872f637e421d914e5ecea99bbe7781f173dc38c")
        add_versions("4.2.0", "676217604a5830cb4aa31e0ede0e4233c942e2fc5c206691bded58ebcd82a590")
    end

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
    end
    add_deps("opengl", {optional = true})

    add_configs("use_external_glfw", {description = "Link raylib against system GLFW instead of embedded one.", default = "OFF", values = {"OFF", "ON", "IF_POSSIBLE"}})
    add_configs("platform", {description = "Platform to build for.", default = "Desktop", values = {"Desktop", "Web", "Android", "Raspberry Pi"}})
    add_configs("opengl_version", {description = "Force a specific OpenGL Version.", default = "OFF", values = {"OFF", "3.3", "2.1", "1.1", "ES 2.0"}})

    on_install("macosx|x86_64", function (package)
        os.cp("include/*.h", package:installdir("include"))
        os.cp("lib/libraylib.a", package:installdir("lib"))
    end)

    on_install("windows", "linux", "macosx|arm64", "mingw", function (package)
        local configs = {"-DBUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCUSTOMIZE_BUILD=ON") -- Needed for the below flags
        table.insert(configs, "USE_EXTERNAL_GLFW=" .. (package:config("use_external_glfw")))
        table.insert(configs, "PLATFORM=" .. (package:config("platform")))
        table.insert(configs, "OPENGL_VERSION=" .. (package:config("opengl_version")))
        import("package.tools.cmake").install(package, configs, {packagedeps = {"libx11", "libxrender", "libxrandr", "libxinerama", "libxcursor", "libxi", "libxfixes", "libxext"}})
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
