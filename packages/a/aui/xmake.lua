package("aui")
    set_homepage("https://github.com/aui-framework/aui")
    set_description("Declarative UI toolkit for modern C++20")
    set_license("MPL-2.0")

    add_urls("https://github.com/aui-framework/aui/archive/refs/tags/$(version).tar.gz",
             "https://github.com/aui-framework/aui.git")

    add_versions("v7.1.2", "a4cf965c50d75e20a319c9c8b231ad9c13c25a06ad303e1eb65d1ff141b1f85c")
    add_patches("v7.1.2", "patches/v7.1.2/debundle.diff", "f5f21bb8813c342a62cde01a7023b106c896236043ab68ea073aefbea51382a9")

    add_deps("cmake")
    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end
    add_deps("zlib")
    -- aui.audio
    add_deps("libopus", "soxr")
    if is_plat("linux") then
        add_syslinks("pulse")
    elseif is_plat("android") then
        add_deps("oboe")
    elseif is_plat("windows", "mingw") then
        add_syslinks("winmm", "dsound", "dxguid")
    elseif is_plat("macosx", "iphoneos") then
        add_frameworks("CoreAudio", "AVFoundation", "AudioToolbox")
        if is_plat("macosx") then
            add_frameworks("AppKit", "Cocoa", "CoreData", "Foundation", "QuartzCore")
        end
    end
    -- aui.core
    add_deps("fmt 9.1.0", "range-v3")
    if is_plat("linux") then
        add_deps("libbacktrace")
        add_syslinks("threads", "dl")
    elseif is_plat("windows", "mingw") then
        add_syslinks("dbghelp", "shlwapi", "kernel32", "psapi")
    elseif is_plat("android") then
        add_syslinks("log")
    end
    -- aui.crypt
    add_deps("openssl3")
    if is_plat("windows", "mingw") then
        add_syslinks("wsock32", "ws2_32")
    end
    -- aui.curl
    add_deps("libcurl")
    -- aui.image
    add_deps("lunasvg", "libwebp")
    -- aui.views
    add_deps("freetype")
    if is_plat("windows", "mingw", "linux", "macosx") then
        add_deps("glew")
        if is_plat("linux") then
            add_deps("libx11", "dbus", "gtk3", "fontconfig")
        end
    end
    if is_plat("windows", "mingw") then
        add_syslinks("dwmapi", "winmm", "shlwapi")
    elseif is_plat("android") then
        add_syslinks("EGL", "GLESv2", "GLESv3")
    elseif is_plat("iphoneos") then
        add_frameworks("OpenGLES")
    elseif is_plat("macosx") then
        add_frameworks("AppKit", "Cocoa", "CoreData", "Foundation", "QuartzCore", "UniformTypeIdentifiers")
    end
    --aui.uitests
    add_deps("gtest", "benchmark")
    --aui.network
    if is_plat("windows", "mingw") then
        add_syslinks("wsock32", "ws2_32", "iphlpapi")
    end

    on_install("!bsd and !wasm", function (package)
        local configs = {
            "-DAUIB_DISABLE=ON"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <AUI/Platform/Entry.h>
            #include <AUI/Logging/ALogger.h>
            #include <AUI/Common/AByteBuffer.h>
            #include <AUI/Url/AUrl.h>
            void test() {
                auto buf = AByteBuffer::fromStream(AUrl(":test.txt").open());
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
