package("raylib")
    set_homepage("http://www.raylib.com")
    set_description("A simple and easy-to-use library to enjoy videogames programming.")
    set_license("zlib")

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
        add_versions("4.5.0", "63deb87ffc32e5eb2023ba763aaea2cb5f41bd37bbc07760651efe251bd76f3d")
        add_versions("5.0", "48e477d3dde2e20220572c9f93a332c48cf378fc1e1f205454b975180085565c")
        add_versions("5.5", "930c67b676963c6cffbd965814664523081ecbf3d30fc9df4211d0064aa6ba39")
    else
        add_urls("https://github.com/raysan5/raylib/archive/$(version).tar.gz",
                 "https://github.com/raysan5/raylib.git")
        add_versions("2.5.0", "fa947329975bdc9ea284019f0edc30ca929535dc78dcf8c19676900d67a845ac")
        add_versions("3.0.0", "164d1cc1710bb8e711a495e84cc585681b30098948d67d482e11dc37d2054eab")
        add_versions("3.5.0", "761985876092fa98a99cbf1fef7ca80c3ee0365fb6a107ab901a272178ba69f5")
        add_versions("3.7.0", "7bfdf2e22f067f16dec62b9d1530186ddba63ec49dbd0ae6a8461b0367c23951")
        add_versions("4.0.0", "11f6087dc7bedf9efb3f69c0c872f637e421d914e5ecea99bbe7781f173dc38c")
        add_versions("4.2.0", "676217604a5830cb4aa31e0ede0e4233c942e2fc5c206691bded58ebcd82a590")
        add_versions("4.5.0", "163378604f2293ea5ebf3238f50c8926addde72d1a6bc8998ac2e96074ba8af8")
        add_versions("5.0", "98f049b9ea2a9c40a14e4e543eeea1a7ec3090ebdcd329c4ca2cf98bc9793482")
        add_versions("5.5", "aea98ecf5bc5c5e0b789a76de0083a21a70457050ea4cc2aec7566935f5e258e")
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
    elseif is_plat("wasm") then
        add_ldflags("-sUSE_GLFW=3", "-sASSERTIONS=1", "-sWASM=1", "-sASYNCIFY", "-sGL_ENABLE_GET_PROC_ADDRESS=1", {force = true})
    elseif is_plat("android") then
        add_syslinks("log", "android", "EGL", "GLESv2", "OpenSLES", "m")
    end
    add_deps("opengl", {optional = true})

    on_install("macosx|x86_64", function (package)
        os.cp("include/*.h", package:installdir("include"))
        os.cp("lib/libraylib.a", package:installdir("lib"))
    end)

    on_install("windows", "linux", "macosx|arm64", "mingw", "wasm", "android", function (package)
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
                InitWindow(100, 100, "hello world!");
            }
        ]]}, {includes = {"raylib.h"}, configs = {languages = "cxx11"}}))
    end)
