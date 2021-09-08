package("guilite")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/idea4good/GuiLite")
    set_description("The smallest header-only GUI library (4 KLOC) for all platforms.")
    set_license("Apache-2.0")

    add_urls("https://github.com/idea4good/GuiLite/archive/refs/tags/$(version).zip",
             "https://github.com/idea4good/GuiLite.git")
    add_versions("v2.1", "53363a5e3a053708b3e081510134fca9bfc635cfdbc9ce01da1ea6ae7e5ba8bc")

    on_install("windows", "macosx", "linux", "mingw", "android", "iphoneos", function (package)
        os.cp("GuiLite.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #define GUILITE_ON
            #include <GuiLite.h>
            void test() {
                c_surface_no_fb surface_no_fb(640, 480, 2, NULL, Z_ORDER_LEVEL_0);
                c_display display(NULL, 640, 480, &surface_no_fb);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
