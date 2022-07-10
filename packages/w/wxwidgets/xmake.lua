package("wxwidgets")
    set_homepage("https://www.wxwidgets.org/")
    set_description("Cross-Platform C++ GUI Library")

    add_urls("https://github.com/wxWidgets/wxWidgets/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wxWidgets/wxWidgets.git")
    add_versions("v3.2.0", "43480e3887f32924246eb439520a3a2bc04d7947712de1ea0590c5b58dedadd9")

    add_deps("cmake")
    add_deps("libjpeg", "libpng", "libtiff")

    on_install("macosx", "linux", "windows", function (package)
        local configs = {"-DwxBUILD_TESTS=OFF",
                         "-DwxBUILD_SAMPLES=OFF",
                         "-DwxBUILD_DEMOS=OFF",
                         "-DwxBUILD_PRECOMP=OFF",
                         "-DwxBUILD_BENCHMARKS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DwxBUILD_DEBUG_LEVEL=" .. (package:debug() and "2" or "0"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            local vs_runtime = package:config("vs_runtime")
            if vs_runtime then
                table.insert(configs, "-DwxBUILD_USE_STATIC_RUNTIME=" .. (vs_runtime:startswith("MT") and "ON" or "OFF"))
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "wx/wxprec.h"
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
        ]]}, {configs = {languages = "c++11"}}))
    end)
