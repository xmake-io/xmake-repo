package("wxwidgets")
    set_homepage("https://www.wxwidgets.org/")
    set_description("Cross-Platform C++ GUI Library")

    if is_plat("windows") then
        if is_arch("x64") then
            add_urls("https://github.com/wxWidgets/wxWidgets/releases/download/v$(version)/wxMSW-$(version)_vc14x_x64_Dev.7z")
            add_versions("3.2.0", "02b7227916b98324f73ae9bed0f1cf27ae3157b4e3a3ded40ee8c0d570f0fd10")
            add_resources("3.2.0", "releaseDLL",
                "https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.0/wxMSW-3.2.0_vc14x_x64_ReleaseDLL.7z",
                "81d6512843a715fd4ba03b227a473701c90fae42406b88f0cc7ca022ec47dc51")
            add_versions("3.2.2", "b5d36e3ac9e01dc1a024344a0a28f9b99bdba75bafa119e1a626d8cc6fdef63d")
            add_resources("3.2.2", "releaseDLL",
                "https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.2/wxMSW-3.2.2_vc14x_x64_ReleaseDLL.7z",
                "34e11c8d493e4f2856441942a88296864243db320e3f9057633d50b89a4f2848")
        else
            add_urls("https://github.com/wxWidgets/wxWidgets/releases/download/v$(version)/wxMSW-$(version)_vc14x_Dev.7z")
            add_versions("3.2.0", "0cd2387edcf1f26924d59efcc3ea4c8a00783ee01bf396756dabdd7967e4b37b")
            add_resources("3.2.0", "releaseDLL",
                "https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.0/wxMSW-3.2.0_vc14x_ReleaseDLL.7z",
                "b168c9225f17168c7ece551c499d043bffc121d32408edf1905648482002110b")
            add_versions("3.2.2", "7150112bece62f4eccd68d3b0eba11b5a1da0f773e864bdecb9840ce76160847")
            add_resources("3.2.2", "releaseDLL",
                "https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.2/wxMSW-3.2.2_vc14x_ReleaseDLL.7z",
                "1a8d387fae963d2242b0fc628699d34bb6141751fb05dec8fa9c0e2784833426")
        end
        add_resources("3.2.0", "headers",
            "https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.0/wxWidgets-3.2.0-headers.7z",
            "bd847e20050c52d127f4afe9b00ffe29d87c2f907749bd6bc732c0db05bce4b1")
        add_resources("3.2.2", "headers",
            "https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.2/wxWidgets-3.2.2-headers.7z",
            "affad097f2c274f796bf08494c1624d999d75727e73959bce5a3d366aeebc721")

        add_configs("shared",     {description = "Build shared library.", default = true, type = "boolean", readonly = true})
        add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MD", readonly = true})
        add_configs("debug",      {description = "Enable debug symbols.", default = false, type = "boolean", readonly = true})
    else
        add_urls("https://github.com/wxWidgets/wxWidgets/archive/refs/tags/$(version).tar.gz",
                 "https://github.com/wxWidgets/wxWidgets.git")
        add_versions("v3.2.0", "43480e3887f32924246eb439520a3a2bc04d7947712de1ea0590c5b58dedadd9")
        add_versions("v3.2.2", "2a4ec4d1af3f22fbfd0a40b051385a5d82628d9f28bae8427f5c30d72bdaade7")

        add_deps("cmake")
        add_deps("libjpeg", "libpng", "nanosvg", "expat", "zlib")
        if is_plat("linux") then
            add_deps("libx11", "libxext", "libxtst")
            add_deps("gtk+3", "opengl", {optional = true})
        end
    end

    if is_plat("macosx") then
        add_defines("__WXOSX_COCOA__", "__WXMAC__", "__WXOSX__", "__WXMAC_XCODE__")
        add_frameworks("AudioToolbox", "WebKit", "CoreFoundation", "Security", "Carbon", "Cocoa", "IOKit", "QuartzCore")
        add_syslinks("iconv")
    elseif is_plat("linux") then
        add_defines("__WXGTK3__", "__WXGTK__")
        add_syslinks("pthread", "m", "dl")
    elseif is_plat("windows") then
        add_defines("WXUSINGDLL", "__WXMSW__", "wxSUFFIX=u", "wxMSVC_VERSION=14x")
        add_links(
            "wxbase32u", "wxbase32u_net", "wxbase32u_xml", "wxexpat",
            "wxjpeg", "wxmsw32u_adv", "wxmsw32u_aui", "wxmsw32u_core", "wxmsw32u_gl",
            "wxmsw32u_html", "wxmsw32u_media", "wxmsw32u_propgrid", "wxmsw32u_qa", "wxmsw32u_ribbon",
            "wxmsw32u_richtext", "wxmsw32u_stc", "wxmsw32u_webview", "wxmsw32u_xrc",
            "wxpng", "wxregexu", "wxscintilla", "wxtiff", "wxzlib"
        )
    end

    on_load(function (package)
        if package:is_plat("macosx", "linux") then
            local version = package:version()
            local suffix = version:major() .. "." .. version:minor()
            local static = package:config("shared") and "" or "-static"
            if package:is_plat("macosx") then
                package:add("includedirs", path.join("lib", "wx", "include", "osx_cocoa-unicode" .. static .. "-" .. suffix))
            elseif package:is_plat("linux") then
                package:add("includedirs", path.join("lib", "wx", "include", "gtk3-unicode" .. static .. "-" .. suffix))
            end
            package:add("includedirs", path.join("include", "wx-" .. suffix))
            if package:debug() then
                package:add("defines", "wxDEBUG_LEVEL=2")
            end
            if package:config("shared") then
                package:add("defines", "WXUSINGDLL")
                package:add("deps", "libtiff", {configs = {shared = true}})
            else
                package:add("deps", "libtiff")
            end
        end
    end)

    on_install("windows", function (package)
        local dlldir = package:is_arch("x64") and "vc14x_x64_dll" or "vc14x_dll"
        os.cp(path.join("lib", dlldir, "*.lib"), package:installdir("lib"))
        os.cp(path.join(package:resourcedir("releaseDLL"),"lib", dlldir, "*.dll"), package:installdir("bin"))
        os.cp(path.join("lib", dlldir, "mswu", "wx"), package:installdir("lib", dlldir, "mswu"))
        os.cp(path.join(package:resourcedir("headers"), "include"), package:installdir())
        os.cp(path.join(package:resourcedir("headers"), "include", "msvc", "wx", "setup.h"), package:installdir("include/wx"))
        io.replace(path.join(package:installdir("include"), "wx", "setup.h"), "../../../lib/", "../../lib/", {plain = true})
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"-DwxBUILD_TESTS=OFF",
                         "-DwxBUILD_SAMPLES=OFF",
                         "-DwxBUILD_DEMOS=OFF",
                         "-DwxBUILD_PRECOMP=OFF",
                         "-DwxBUILD_BENCHMARKS=OFF",
                         "-DwxUSE_REGEX=sys",
                         "-DwxUSE_ZLIB=sys",
                         "-DwxUSE_EXPAT=sys",
                         "-DwxUSE_LIBJPEG=sys",
                         "-DwxUSE_LIBPNG=sys",
                         "-DwxUSE_NANOSVG=sys",
                         "-DwxUSE_LIBTIFF=sys"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:debug() then
            table.insert(configs, "-DwxBUILD_DEBUG_LEVEL=2")
        end
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        local version = package:version()
        local subdir = "wx-" .. version:major() .. "." .. version:minor()
        local setupdir = package:is_plat("macosx") and "osx" or "gtk"
        os.cp(path.join(package:installdir("include", subdir, "wx", setupdir, "setup.h")),
              path.join(package:installdir("include", subdir, "wx")))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "wx/wx.h"
            #include "wx/app.h"
            #include "wx/cmdline.h"
            void test() {
                wxApp::CheckBuildOptions(WX_BUILD_OPTIONS_SIGNATURE, "program");
                wxInitializer initializer;
                if (!initializer) {
                    fprintf(stderr, "Failed to initialize the wxWidgets library, aborting.");
                }
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
