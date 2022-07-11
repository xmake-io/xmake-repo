package("wxwidgets")
    set_homepage("https://www.wxwidgets.org/")
    set_description("Cross-Platform C++ GUI Library")

    if is_plat("windows") then
        if is_arch("x64") then
            add_urls("https://github.com/wxWidgets/wxWidgets/releases/download/v$(version)/wxMSW-$(version)_vc14x_x64_Dev.7z")
            add_versions("3.2.0", "02b7227916b98324f73ae9bed0f1cf27ae3157b4e3a3ded40ee8c0d570f0fd10")
        else
            add_urls("https://github.com/wxWidgets/wxWidgets/releases/download/v$(version)/wxMSW-$(version)_vc14x_Dev.7z")
            add_versions("3.2.0", "0cd2387edcf1f26924d59efcc3ea4c8a00783ee01bf396756dabdd7967e4b37b")
        end
        add_resources("3.2.0", "headers",
            "https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.0/wxWidgets-3.2.0-headers.7z",
            "bd847e20050c52d127f4afe9b00ffe29d87c2f907749bd6bc732c0db05bce4b1")

        add_configs("shared",     {description = "Build shared library.", default = true, type = "boolean", readonly = true})
        add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MD", readonly = true})
    else
        add_urls("https://github.com/wxWidgets/wxWidgets/archive/refs/tags/$(version).tar.gz",
                 "https://github.com/wxWidgets/wxWidgets.git")
        add_versions("v3.2.0", "43480e3887f32924246eb439520a3a2bc04d7947712de1ea0590c5b58dedadd9")

        add_deps("cmake")
        add_deps("libjpeg", "libpng", "nanosvg", "expat", "zlib")
        if is_plat("linux") then
            add_deps("pkg-config")
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
        add_defines("WXUSINGDLL", "__WXMSW__", "wxSUFFIX=ud", "wxMSVC_VERSION=14x")
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
        os.cp(path.join("lib", dlldir, "*.pdb"), package:installdir("lib"))
        os.cp(path.join("lib", dlldir, "*.dll"), package:installdir("bin"))
        os.cp(path.join("lib", dlldir, "mswud", "wx"), package:installdir("lib", dlldir, "mswud"))
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
