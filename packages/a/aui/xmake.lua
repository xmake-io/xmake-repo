package("aui")
    set_homepage("https://github.com/aui-framework/aui")
    set_description("Declarative UI toolkit for modern C++20")
    set_license("MPL-2.0")

    add_urls("https://github.com/aui-framework/aui/archive/refs/tags/$(version).tar.gz",
             "https://github.com/aui-framework/aui.git")

    add_versions("v7.1.2", "a4cf965c50d75e20a319c9c8b231ad9c13c25a06ad303e1eb65d1ff141b1f85c")

    add_patches("v7.1.2", "patches/v7.1.2/debundle-audio.diff", "1707040d98dafac81883fac05b73b3c74e6b8cb957e6a5108565d5b49948daf9")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-build.diff", "92bfd68e28a703518c12cf51b898a6b75cacae1fec9384328562c47b003e9577")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-core.diff", "2ab1e7181d07b64bb059b8b7fdff69c295df84043560ecb337516c649ac28bbe")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-crypt.diff", "58045d168a8c7f2658554e0a3010579ec53b54e2c51f524a4fb61e5e4d6fc0a7")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-curl.diff", "937280a828ce0bc30a590606e7d65de55c9421d0650897c2d775e3731405a4b0")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-image.diff", "44bb7e78eab9629c92ef953ec1e0aca9e80712fe2488d6ffa804924d418ebf05")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-json-network.diff", "6d7d8da64cf85212e14757f7d24ac5ac6501dfd0ff3a4fcbe973c7c58c4f213c")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-main.diff", "c1cac9dfbae14baaddb68837055a7a858c08786750a16cbbfe955a1f18e5878d")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-sqlite.diff", "1728a4b9afc473acc81b16c544239e6f70a147c0623d894d59dd124e27c94311")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-toolbox.diff", "1ec1abf993eb7e583d32602e1ae8ee4d3358d156e9fac185c0d19ed85660bd3b")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-uitests.diff", "831a208eff22c5536ada4ea4a4e2496868977c2ee9b7d7e534bc6bdeae537d86")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-views.diff", "9247b2986de53510f26d05cd25b35b449bda34b1acc97e601d16f933c14afe6c")
    add_patches("v7.1.2", "patches/v7.1.2/fix-backport-lunasvg.diff", "daf24391b88e44bdb801b2c1ba36a695f95384d8157ccb23cfc635d5f30bea4a")
    add_patches("v7.1.2", "patches/v7.1.2/fix-msvc-pretty-function.diff", "268f66f42594f0188fe50d33f5783e66f66024087097ebfdfef60c9768e151fd")
    add_patches("v7.1.2", "patches/v7.1.2/fix-osx-enforce-cpp-template.diff", "eef4147a8b037552887777cd497c190ecc22514bb11fb3a3d6ea433a78cce61b")
    add_patches("v7.1.2", "patches/v7.1.2/fixup-network.diff", "888c1ed0e96f21bd842de72f8f9fe933261c5f76c99be55cf8e83f424bd1f79e")

    add_deps("cmake")
    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end
    add_deps("zlib")

    -- aui.audio
    on_component("audio", function (package, component)
        package:add("includedirs", "aui.audio/include")
        component:add("links", "aui.audio")
        package:add("deps", "libopus", "soxr")
        if package:is_plat("linux") then
            component:add("deps", "pulseaudio")
        elseif package:is_plat("android") then
            package:add("deps", "oboe")
        elseif package:is_plat("windows", "mingw") then
            component:add("syslinks", "winmm", "dsound", "dxguid")
        elseif package:is_plat("macosx", "iphoneos") then
            component:add("frameworks", "CoreAudio", "AVFoundation", "AudioToolbox")
            if package:is_plat("macosx") then
                component:add("frameworks", "AppKit", "Cocoa", "CoreData", "Foundation", "QuartzCore")
            end
        end
    end)

    -- aui.core
    on_component("core", function (package, component)
        package:add("includedirs", "aui.core/include")
        component:add("links", "aui.core")
        package:add("deps", "fmt 9.1.0", "range-v3", "glm")
        if package:is_plat("linux") then
            package:add("deps", "libbacktrace")
            component:add("syslinks", "threads", "dl")
        elseif package:is_plat("windows", "mingw") then
            component:add("syslinks", "dbghelp", "shell32", "shlwapi", "kernel32", "psapi")
        elseif package:is_plat("android") then
            component:add("syslinks", "log")
        end
    end)

    -- aui.crypt
    on_component("crypt", function (package, component)
        package:add("includedirs", "aui.crypt/include")
        component:add("links", "aui.crypt")
        package:add("deps", "openssl3")
        if package:is_plat("windows", "mingw") then
            component:add("syslinks", "wsock32", "ws2_32")
        end
    end)

    -- aui.curl
    on_component("curl", function (package, component)
        package:add("includedirs", "aui.curl/include")
        component:add("links", "aui.curl")
        package:add("deps", "libcurl")
    end)

    -- aui.image
    on_component("image", function (package, component)
        package:add("includedirs", "aui.image/include")
        component:add("links", "aui.image")
        package:add("deps", "lunasvg", "libwebp")
    end)

    -- aui.json
    on_component("json", function (package, component)
        package:add("includedirs", "aui.json/include")
        component:add("links", "aui.json")
    end)

    -- aui.network
    on_component("network", function (package, component)
        package:add("includedirs", "aui.network/include")
        component:add("links", "aui.network")
        if package:is_plat("windows", "mingw") then
            component:add("syslinks", "wsock32", "ws2_32", "iphlpapi")
        end
    end)

    -- aui.toolbox
    on_component("toolbox", function (package, component)
        package:add("includedirs", "aui.toolbox/include")
    end)

    -- aui.uitests
    on_component("uitests", function (package, component)
        package:add("includedirs", "aui.uitests/include")
        component:add("links", "aui.uitests")
        package:add("deps", "gtest", "benchmark")
    end)

    -- aui.views
    on_component("views", function (package, component)
        package:add("includedirs", "aui.views/include")
        component:add("links", "aui.views")
        package:add("deps", "freetype")
        if package:is_plat("windows", "mingw", "linux", "macosx") then
            package:add("deps", "glew")
        end
        if package:is_plat("linux") then
            package:add("deps", "libx11", "dbus", "gtk3", "fontconfig")
        end
        if package:is_plat("windows", "mingw") then
            component:add("syslinks", "dwmapi", "winmm", "shlwapi", "gdi32", "ole32")
        elseif package:is_plat("android") then
            component:add("syslinks", "EGL", "GLESv2", "GLESv3")
        elseif package:is_plat("iphoneos") then
            component:add("frameworks", "OpenGLES")
        elseif package:is_plat("macosx") then
            component:add("frameworks", "AppKit", "Cocoa", "CoreData", "Foundation", "QuartzCore", "UniformTypeIdentifiers", "OpenGL")
        end
    end)

    -- aui.xml
    on_component("xml", function (package, component)
        package:add("includedirs", "aui.xml/include")
        component:add("links", "aui.xml")
    end)

    on_load(function (package)
        package:add("components", "audio", "core", "crypt", "curl", "image", "json", "network", "toolbox", "uitests", "views", "xml")
        if not package:config("shared") then
            package:add("defines", "AUI_STATIC")
        end
        package:add("defines", "AUI_DEBUG=" .. (package:is_debug() and "1" or "0"))
        package:add("defines",
            "API_AUI_AUDIO=AUI_IMPORT",
            "API_AUI_CORE=AUI_IMPORT",
            "API_AUI_CRYPT=AUI_IMPORT",
            "API_AUI_CURL=AUI_IMPORT",
            "API_AUI_DATA=AUI_IMPORT",
            "API_AUI_IMAGE=AUI_IMPORT",
            "API_AUI_JSON=AUI_IMPORT",
            "API_AUI_NETWORK=AUI_IMPORT",
            "API_AUI_UITESTS=AUI_IMPORT",
            "API_AUI_UPDATER=AUI_IMPORT",
            "API_AUI_VIEWS=AUI_IMPORT",
            "API_AUI_XML=AUI_IMPORT"
        )
        if package:is_plat("windows", "mingw") then
            package:add("defines",
                "AUI_PLATFORM_WIN=1", "AUI_PLATFORM_LINUX=0",
                "AUI_PLATFORM_APPLE=0", "AUI_PLATFORM_MACOS=0",
                "AUI_PLATFORM_IOS=0", "AUI_PLATFORM_ANDROID=0",
                "AUI_PLATFORM_UNIX=0", "AUI_PLATFORM_EMSCRIPTEN=0"
            )
        elseif package:is_plat("linux") then
            package:add("defines",
                "AUI_PLATFORM_WIN=0", "AUI_PLATFORM_LINUX=1",
                "AUI_PLATFORM_APPLE=0", "AUI_PLATFORM_MACOS=0",
                "AUI_PLATFORM_IOS=0", "AUI_PLATFORM_ANDROID=0",
                "AUI_PLATFORM_UNIX=1", "AUI_PLATFORM_EMSCRIPTEN=0"
            )
        elseif package:is_plat("macosx") then
            package:add("defines",
                "AUI_PLATFORM_WIN=0", "AUI_PLATFORM_LINUX=0",
                "AUI_PLATFORM_APPLE=1", "AUI_PLATFORM_MACOS=1",
                "AUI_PLATFORM_IOS=0", "AUI_PLATFORM_ANDROID=0",
                "AUI_PLATFORM_UNIX=1", "AUI_PLATFORM_EMSCRIPTEN=0"
            )
        elseif package:is_plat("android") then
            package:add("defines",
                "AUI_PLATFORM_WIN=0", "AUI_PLATFORM_LINUX=0",
                "AUI_PLATFORM_APPLE=0", "AUI_PLATFORM_MACOS=0",
                "AUI_PLATFORM_IOS=0", "AUI_PLATFORM_ANDROID=1",
                "AUI_PLATFORM_UNIX=1", "AUI_PLATFORM_EMSCRIPTEN=0"
            )
        elseif package:is_plat("iphoneos") then
            package:add("defines",
                "AUI_PLATFORM_WIN=0", "AUI_PLATFORM_LINUX=0",
                "AUI_PLATFORM_APPLE=1", "AUI_PLATFORM_MACOS=0",
                "AUI_PLATFORM_IOS=1", "AUI_PLATFORM_ANDROID=0",
                "AUI_PLATFORM_UNIX=1", "AUI_PLATFORM_EMSCRIPTEN=0"
            )
        elseif package:is_plat("wasm") then
            package:add("defines",
                "AUI_PLATFORM_WIN=0", "AUI_PLATFORM_LINUX=0",
                "AUI_PLATFORM_APPLE=0", "AUI_PLATFORM_MACOS=0",
                "AUI_PLATFORM_IOS=0", "AUI_PLATFORM_ANDROID=0",
                "AUI_PLATFORM_UNIX=0", "AUI_PLATFORM_EMSCRIPTEN=1"
            )
        end
        if package:has_tool("cxx", "clang", "clangxx", "clang++") then
            package:add("defines", "AUI_COMPILER_CLANG=1", "AUI_COMPILER_GCC=0", "AUI_COMPILER_MSVC=0")
        elseif package:has_tool("cxx", "gcc", "gxx", "g++") then
            package:add("defines", "AUI_COMPILER_CLANG=0", "AUI_COMPILER_GCC=1", "AUI_COMPILER_MSVC=0")
        elseif package:has_tool("cxx", "cl") then
            package:add("defines", "AUI_COMPILER_CLANG=0", "AUI_COMPILER_GCC=0", "AUI_COMPILER_MSVC=1")
        end
        if package:is_arch("arm.*") then
            if package:check_sizeof("void*") == "4" then
                package:add("defines", "AUI_ARCH_X86=0", "AUI_ARCH_X86_64=0", "AUI_ARCH_ARM_64=0", "AUI_ARCH_ARM_V7=1")
            else
                package:add("defines", "AUI_ARCH_X86=0", "AUI_ARCH_X86_64=0", "AUI_ARCH_ARM_64=1", "AUI_ARCH_ARM_V7=0")
            end
        else
            if package:check_sizeof("void*") == "4" then
                package:add("defines", "AUI_ARCH_X86=1", "AUI_ARCH_X86_64=0", "AUI_ARCH_ARM_64=0", "AUI_ARCH_ARM_V7=0")
            else
                package:add("defines", "AUI_ARCH_X86=0", "AUI_ARCH_X86_64=1", "AUI_ARCH_ARM_64=0", "AUI_ARCH_ARM_V7=0")
            end
        end
        package:add("defines", "GLM_ENABLE_EXPERIMENTAL=1")
    end)

    on_install("windows", "macosx", "linux", "mingw", function (package)
        local configs = {
            "-DAUI_INSTALL_RUNTIME_DEPENDENCIES=OFF",
            "-DAUIB_NO_PRECOMPILED=TRUE",
            "-DAUIB_DISABLE=ON"
        }
        local opt = {}
        if package:is_plat("linux") then
            opt.packagedeps = {"pulseaudio"}
        elseif package:is_plat("macosx") then
            if package:config("shared") then
                opt.packagedeps = {"gtest"}
            end
        elseif package:is_plat("windows", "mingw") then
            opt.packagedeps = {"glew", "gtest"}
            if package:has_tool("cxx", "cl", "clang_cl") then
                opt.cxflags = {"/EHsc"}
            end
            if package:targetarch():startswith("arm") then
                io.replace("cmake/aui.build.cmake", [[if (CMAKE_GENERATOR_PLATFORM MATCHES "(arm64)|(ARM64)" OR CMAKE_SYSTEM_PROCESSOR MATCHES "(aarch64|arm64)")]], [[if (1)]], {plain = true})
            end
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <AUI/Platform/AWindow.h>
            #include <AUI/Util/UIBuildingHelpers.h>
            #include <AUI/View/ALabel.h>
            #include <AUI/View/AButton.h>
            #include <AUI/Platform/APlatform.h>
            #include <AUI/Platform/Entry.h>
            using namespace declarative;
            class MainWindow: public AWindow {
            public:
                MainWindow();
            };
            MainWindow::MainWindow(): AWindow("Project template app", 300_dp, 200_dp) {
                setContents(
                    Centered{
                        Vertical{
                            Centered { Label { "Hello world from AUI!" } },
                            _new<AButton>("Visit GitHub repo").connect(&AView::clicked, this, [] {
                                APlatform::openUrl("https://github.com/aui-framework/aui");
                            }),
                            _new<AButton>("Visit docs").connect(&AView::clicked, this, [] {
                                APlatform::openUrl("https://aui-framework.github.io/");
                            }),
                            _new<AButton>("Submit an issue").connect(&AView::clicked, this, [] {
                                APlatform::openUrl("https://github.com/aui-framework/aui/issues/new");
                            }),
                        }
                    }
                );
            }
            void test() {
                _new<MainWindow>()->show();
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
