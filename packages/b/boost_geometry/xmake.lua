package("boost_geometry")
    set_kind("library", {headeronly = true})
    set_homepage("http://boost.org/libs/geometry")
    set_description("Boost.Geometry - Generic Geometry Library | Requires C++14 since Boost 1.75")
    set_license("BSL-1.0")

    add_urls("https://github.com/boostorg/geometry/archive/refs/tags/boost-$(version).tar.gz",
             "https://github.com/boostorg/geometry.git")

    add_versions("1.85.0", "6158af6ede544400dbce515e6afc70d326e6fd10d13ffc8947aa1867dcc2b0a0")

    add_deps("boost")

    on_install("macosx", "linux", "windows", "bsd", "mingw", "cross", function (package)
        os.cp("include", package:installdir(""))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <boost/geometry/geometry.hpp>
            void test() {
                using namespace boost::geometry;
                model::point<double, 2, cs::cartesian> pt1;
            }
        ]]}, {configs = {languages = "cxx14"}}))
    end)
