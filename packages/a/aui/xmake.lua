package("aui")
    set_homepage("https://github.com/aui-framework/aui")
    set_description("Declarative UI toolkit for modern C++20")
    set_license("MPL-2.0")

    add_urls("https://github.com/aui-framework/aui/archive/refs/tags/$(version).tar.gz",
             "https://github.com/aui-framework/aui.git")

    add_versions("v7.1.2", "a4cf965c50d75e20a319c9c8b231ad9c13c25a06ad303e1eb65d1ff141b1f85c")

    add_patches("v7.1.2", "patches/v7.1.2/debundle-audio.diff", "464d798caaf366f3fadb689504584ad38b15af05c4f044c74c8290a151b082d9")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-build.diff", "92bfd68e28a703518c12cf51b898a6b75cacae1fec9384328562c47b003e9577")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-core.diff", "eceb483a998e2840534560940b2f2beddcf0a107f4cd388623011db9653ee567")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-crypt.diff", "58045d168a8c7f2658554e0a3010579ec53b54e2c51f524a4fb61e5e4d6fc0a7")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-curl.diff", "937280a828ce0bc30a590606e7d65de55c9421d0650897c2d775e3731405a4b0")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-image.diff", "44bb7e78eab9629c92ef953ec1e0aca9e80712fe2488d6ffa804924d418ebf05")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-json-network.diff", "6d7d8da64cf85212e14757f7d24ac5ac6501dfd0ff3a4fcbe973c7c58c4f213c")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-main.diff", "f9f5400579465cf07087a91633571b8b01c73cdc8dcc3ef4144da16528d53f8a")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-sqlite.diff", "1728a4b9afc473acc81b16c544239e6f70a147c0623d894d59dd124e27c94311")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-toolbox.diff", "1ec1abf993eb7e583d32602e1ae8ee4d3358d156e9fac185c0d19ed85660bd3b")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-uitests.diff", "831a208eff22c5536ada4ea4a4e2496868977c2ee9b7d7e534bc6bdeae537d86")
    add_patches("v7.1.2", "patches/v7.1.2/debundle-views.diff", "b691b46fc425f7c497de18b77b4ad2ac62cf61c983688f2402a50d727770e28f")
    add_patches("v7.1.2", "patches/v7.1.2/fix-backport-lunasvg.diff", "daf24391b88e44bdb801b2c1ba36a695f95384d8157ccb23cfc635d5f30bea4a")
    add_patches("v7.1.2", "patches/v7.1.2/fix-msvc-pretty-function.diff", "268f66f42594f0188fe50d33f5783e66f66024087097ebfdfef60c9768e151fd")
    add_patches("v7.1.2", "patches/v7.1.2/fix-osx-enforce-cpp-template.diff", "eef4147a8b037552887777cd497c190ecc22514bb11fb3a3d6ea433a78cce61b")

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
        package:add("includedirs", "aui.xml/include")
        component:add("links", "aui.xml")
    end)

    on_load(function (package)
        package:add("components", "audio", "core", "crypt", "curl", "image", "json", "network", "toolbox", "uitests", "views", "xml")
        if not package:config("shared") then
            package:add("defines", "AUI_STATIC")
        end
        package:add("defines", "AUI_DEBUG=" .. (package:is_debug() and "1" or "0"))
        package:add("defines", "API_AUI_CORE=AUI_IMPORT")
        package:add("defines", "GLM_ENABLE_EXPERIMENTAL=1")
    end)

    on_install("windows|!arm*", "macosx", function (package)
        local configs = {
            "-DAUI_INSTALL_RUNTIME_DEPENDENCIES=OFF",
            "-DAUIB_NO_PRECOMPILED=TRUE",
            "-DAUIB_DISABLE=ON"
        }        
        local opt = {}
        if package:is_plat("macosx") then
            if package:config("shared") then
                opt.packagedeps = {"gtest"}
            end
        elseif package:is_plat("windows") then
            if package:config("shared") then
                opt.packagedeps = {"glew", "gtest"}
            end
            if package:has_tool("cxx", "cl", "clang_cl") then
                opt.cxflags = {"/EHsc"}
            end
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, opt)
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
