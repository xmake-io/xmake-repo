package("half")
    set_kind("library", {headeronly = true})
    set_homepage("https://half.sourceforge.net")
    set_description("C++ library for half precision floating point arithmetics")
    set_license("MIT")

    add_urls("https://downloads.sourceforge.net/project/half/half/$(version)/half-$(version).zip")
    add_versions("2.2.0", "1d1d9e482fb95fcd7cab0953a4bd35e00b86578f11cb6939a067811a055a563b")

    on_install("windows", "linux", "macosx", "iphoneos", "android", "bsd", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                half_float::half a{ 3.1415926f };
                float b{ a };
            }
        ]]}, {configs = {languages = "c++11"}, includes = "half.hpp"}))
    end)
