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
            add_versions("3.2.3", "b8a6be72378d9947e303d7075a58c9bbc161d5debd25a187b654373b4d204873")
            add_resources("3.2.3", "releaseDLL",
                "https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.3/wxMSW-3.2.3_vc14x_x64_ReleaseDLL.7z",
                "ee0fde533b7ac8eac6ec112da2e3a488675aa8c1dda483eb8a9a2d4f8e5bb734")
            add_versions("3.2.4", "b8be152f08031aed2bfeffd17d8409209c38667859094b319818e08f7a4ad065")
            add_resources("3.2.4", "releaseDLL",
                "https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.4/wxMSW-3.2.4_vc14x_x64_ReleaseDLL.7z",
                "0f9108e64f98978580fee2d4b3a53451ab4333e4b47dde45b82e7867d0bbfc2c")
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
            add_versions("3.2.3", "8961f24abb16362a542140912f3c6cb75b8f95111816311ecf5b00ea1e0c55f3")
            add_resources("3.2.3", "releaseDLL",
                "https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.3/wxMSW-3.2.3_vc14x_ReleaseDLL.7z",
                "b1b22d43509c2e1fe427d038210076dcb1d9953e5fef09ffa04e49f49c78a9a7")
            add_versions("3.2.4", "efa6bf76d42373e7930af18a176e5e52fbdd43f5da41b9bf6cd3b347d820f8b7")
            add_resources("3.2.4", "releaseDLL",
                "https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.4/wxMSW-3.2.4_vc14x_ReleaseDLL.7z",
                "240308cb9ffb718ab2f1298238c6e6aea7708cb16aca5801a03bffee6f9ef673")
        end
        add_resources("3.2.0", "headers",
            "https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.0/wxWidgets-3.2.0-headers.7z",
            "bd847e20050c52d127f4afe9b00ffe29d87c2f907749bd6bc732c0db05bce4b1")
        add_resources("3.2.2", "headers",
            "https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.2/wxWidgets-3.2.2-headers.7z",
            "affad097f2c274f796bf08494c1624d999d75727e73959bce5a3d366aeebc721")
        add_resources("3.2.3", "headers",
            "https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.3/wxWidgets-3.2.3-headers.7z",
            "a610f1a044b93f4d8d5439c67fc42b3feb168d854bc4725aa2b5ff4569d89a06")
        add_resources("3.2.4", "headers",
            "https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.4/wxWidgets-3.2.4-headers.7z",
            "b8c4fd1a62c104c65089a088670d80e827b3893b7425c1cab8d7e49879797326")

        add_configs("shared",     {description = "Build shared library.", default = true, type = "boolean", readonly = true})
        add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MD", readonly = true})
        add_configs("debug",      {description = "Enable debug symbols.", default = false, type = "boolean", readonly = true})
    else
        add_urls("https://github.com/wxWidgets/wxWidgets/releases/download/v$(version)/wxWidgets-$(version).tar.bz2",
                 "https://github.com/wxWidgets/wxWidgets.git")
        add_versions("3.2.0", "356e9b55f1ae3d58ae1fed61478e9b754d46b820913e3bfbc971c50377c1903a")
        add_versions("3.2.2", "8edf18672b7bc0996ee6b7caa2bee017a9be604aad1ee471e243df7471f5db5d")
        add_versions("3.2.3", "c170ab67c7e167387162276aea84e055ee58424486404bba692c401730d1a67a")
        add_versions("3.2.4", "0640e1ab716db5af2ecb7389dbef6138d7679261fbff730d23845ba838ca133e")
        add_versions("3.2.5", "0ad86a3ad3e2e519b6a705248fc9226e3a09bbf069c6c692a02acf7c2d1c6b51")

        add_deps("cmake")
        add_deps("libjpeg", "libpng", "nanosvg", "expat", "zlib", "pango", "glib")
        if is_plat("linux") then
            add_deps("opengl", "at-spi2-core")
            add_patches("<=3.2.5", "patches/3.2.5/add_libdir.patch", "9a9fe4d745b4b6b09998ec7a93642d69761a8779d203fbb42a3df8c3d62adeb0")
        end
    end

    if is_plat("macosx") then
        add_defines("__WXOSX_COCOA__", "__WXMAC__", "__WXOSX__", "__WXMAC_XCODE__")
        add_frameworks("AudioToolbox", "WebKit", "CoreFoundation", "Security", "Carbon", "Cocoa", "IOKit", "QuartzCore")
        add_syslinks("iconv")
    elseif is_plat("linux") then
        add_defines("__WXGTK3__", "__WXGTK__")
        add_syslinks("pthread", "m", "dl")
        add_syslinks("X11", "Xext", "Xtst", "xkbcommon")
        add_links(
            "pango-1.0", "pangoxft-1.0", "pangocairo-1.0", "pangoft2-1.0"
        )
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
            if package:is_debug() then
                package:add("defines", "wxDEBUG_LEVEL=2")
            end
            if package:config("shared") then
                package:add("defines", "WXUSINGDLL")
                package:add("deps", "libtiff", {configs = {shared = true}})
                package:add("deps", "gdk-pixbuf", {configs = {shared = true}})
            else
                package:add("deps", "libtiff")
                package:add("deps", "gdk-pixbuf")
            end

            if package:is_plat("linux") then
                 if package:config("shared") then
                    package:add("deps", "gtk3", {configs = {shared = true}})
                else
                    package:add("deps", "gtk3")
                end
            end
        end
    end)

    on_install("windows|x86", "windows|x64", function (package)
        local dlldir = package:is_arch("x64") and "vc14x_x64_dll" or "vc14x_dll"
        os.cp(path.join("lib", dlldir, "*.lib"), package:installdir("lib"))
        os.cp(path.join(package:resourcedir("releaseDLL"),"lib", dlldir, "*.dll"), package:installdir("bin"))
        os.cp(path.join("lib", dlldir, "mswu", "wx"), package:installdir("lib", dlldir, "mswu"))
        os.cp(path.join(package:resourcedir("headers"), "include"), package:installdir())
        os.cp(path.join(package:resourcedir("headers"), "include", "msvc", "wx", "setup.h"), package:installdir("include/wx"))
        io.replace(path.join(package:installdir("include"), "wx", "setup.h"), "../../../lib/", "../../lib/", {plain = true})
    end)

    on_install("macosx", "linux", function (package)
        import("core.base.semver")
        import("utils.ci.is_running", {alias = "ci_is_running"})

        -- Notify the user about issues caused by the CMake version.
        local cmake = package:dep("cmake")
        local cmake_fetch = cmake:fetch()
        if cmake_fetch and cmake_fetch.version and semver.match(cmake_fetch.version):gt("3.28.0") then
            wprint("cmake may not find Cmath detail in https://github.com/prusa3d/PrusaSlicer/issues/12169\n")
        end

        io.replace("build/cmake/modules/FindGTK3.cmake", "FIND_PACKAGE_HANDLE_STANDARD_ARGS(GTK3 DEFAULT_MSG GTK3_INCLUDE_DIRS GTK3_LIBRARIES VERSION_OK)", 
                                                         [[FIND_PACKAGE_HANDLE_STANDARD_ARGS(GTK3 DEFAULT_MSG GTK3_INCLUDE_DIRS GTK3_LIBRARY_DIRS GTK3_LIBRARIES VERSION_OK)]], {plain = true})
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
                         "-DwxUSE_LIBTIFF=builtin"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:is_debug() then
            table.insert(configs, "-DwxBUILD_DEBUG_LEVEL=2")
        end
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {jobs = ci_is_running() and 1 or nil})
        
        local version = package:version()
        local subdir = "wx-" .. version:major() .. "." .. version:minor()
        local setupdir = package:is_plat("macosx") and "osx" or "gtk"
        os.cp(path.join(package:installdir("include", subdir, "wx", setupdir, "setup.h")),
              path.join(package:installdir("include", subdir, "wx")))
        local lib_suffix = version:major() .. "." .. version:minor()
        if package:is_plat("linux") then
            package:add("links", "wx_gtk3u_xrc-" .. lib_suffix, "wx_gtk3u_html-" .. lib_suffix, "wx_gtk3u_qa-" .. lib_suffix, "wx_gtk3u_core-" .. lib_suffix, "wx_baseu_xml-" .. lib_suffix, "wx_baseu_net-" .. lib_suffix, "wx_baseu-" .. lib_suffix)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <wx/wxprec.h>
            #ifndef WX_PRECOMP
                #include <wx/wx.h>
            #endif
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
