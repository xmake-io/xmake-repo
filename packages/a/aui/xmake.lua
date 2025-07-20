package("aui")
    set_homepage("https://github.com/aui-framework/aui")
    set_description("Declarative UI toolkit for modern C++20")
    set_license("MPL-2.0")

    add_urls("https://github.com/aui-framework/aui/archive/refs/tags/$(version).tar.gz",
             "https://github.com/aui-framework/aui.git")

    add_versions("v7.1.2", "a4cf965c50d75e20a319c9c8b231ad9c13c25a06ad303e1eb65d1ff141b1f85c")
    add_patches("v7.1.2", "patches/v7.1.2/debundle.diff", "1eb3da88e82503e6a9a893c112b4dd97909341905fe0e28d3fb5a4d2a50075ea")

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
            component:add("syslinks", "pulse")
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
        component:add("includedirs", "aui.core/include")
        component:add("links", "aui.core")
        package:add("deps", "fmt 9.1.0", "range-v3")
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
        component:add("includedirs", "aui.crypt/include")
        component:add("links", "aui.crypt")
        package:add("deps", "openssl3")
        if package:is_plat("windows", "mingw") then
            component:add("syslinks", "wsock32", "ws2_32")
        end
    end)

    -- aui.curl
    on_component("curl", function (package, component)
        component:add("includedirs", "aui.curl/include")
        component:add("links", "aui.curl")
        package:add("deps", "libcurl")
    end)

    -- aui.image
    on_component("image", function (package, component)
        component:add("includedirs", "aui.image/include")
        component:add("links", "aui.image")
        package:add("deps", "lunasvg", "libwebp")
    end)

    -- aui.json
    on_component("json", function (package, component)
        component:add("includedirs", "aui.json/include")
        component:add("links", "aui.json")
    end)

    -- aui.network
    on_component("network", function (package, component)
        component:add("includedirs", "aui.network/include")
        component:add("links", "aui.network")
        if package:is_plat("windows", "mingw") then
            component:add("syslinks", "wsock32", "ws2_32", "iphlpapi")
        end
    end)

    -- aui.toolbox
    on_component("toolbox", function (package, component)
        component:add("includedirs", "aui.toolbox/include")
    end)

    -- aui.uitests
    on_component("uitests", function (package, component)
        component:add("includedirs", "aui.uitests/include")
        component:add("links", "aui.uitests")
        package:add("deps", "gtest", "benchmark")
    end)

    -- aui.views
    on_component("views", function (package, component)
        component:add("includedirs", "aui.views/include")
        component:add("links", "aui.views")
        package:add("deps", "freetype")
        if package:is_plat("windows", "mingw", "linux", "macosx") then
            package:add("deps", "glew")
        end
        if package:is_plat("linux") then
            package:add("deps", "libx11", "dbus", "gtk3", "fontconfig")
        end
        if package:is_plat("windows", "mingw") then
            component:add("syslinks", "dwmapi", "winmm", "shlwapi")
        elseif package:is_plat("android") then
            component:add("syslinks", "EGL", "GLESv2", "GLESv3")
        elseif package:is_plat("iphoneos") then
            component:add("frameworks", "OpenGLES")
        elseif package:is_plat("macosx") then
            component:add("frameworks", "AppKit", "Cocoa", "CoreData", "Foundation", "QuartzCore", "UniformTypeIdentifiers")
        end
    end)

    -- aui.xml
    on_component("xml", function (package, component)
        component:add("includedirs", "aui.xml/include")
        component:add("links", "aui.xml")
    end)

    on_load(function (package)
        package:add("components", "audio", "core", "crypt", "curl", "image", "json", "network", "toolbox", "uitests", "views", "xml")
        if not package:config("shared") then
            package:add("defines", "AUI_STATIC")
        end
        package:add("defines", "AUI_DEBUG=" .. (package:is_debug() and "1" or "0"))
        package:add("defines", "API_AUI_CORE=AUI_IMPORT")
    end)

    on_install("!bsd and !wasm", function (package)
        local configs = {
            "-DAUIB_NO_PRECOMPILED=TRUE",
            "-DAUIB_DISABLE=ON"
        }
        if package:is_plat("windows") and package:is_arch("arm64") then
            io.replace("cmake/aui.build.cmake", [[if (CMAKE_GENERATOR_PLATFORM MATCHES "(arm64)|(ARM64)" OR CMAKE_SYSTEM_PROCESSOR MATCHES "(aarch64|arm64)")]], [[if (1)]], {plain = true})
        end
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
