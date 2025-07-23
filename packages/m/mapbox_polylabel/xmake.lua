package("mapbox_polylabel")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/mapbox/polylabel")
    set_description("A fast algorithm for finding the pole of inaccessibility of a polygon (in JavaScript and C++)")
    set_license("ISC")

    add_urls("https://github.com/mapbox/polylabel/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mapbox/polylabel.git")

    add_versions("v2.0.1", "d51ec39f9f1bc46c551dfdf642f72057a8c2cde2c5e89bc70e0bd712fad63a75")
    add_versions("v2.0.0", "9aba4320c6cb5a8e9a8d44feb0d68b79b3127bdcb759a26aca92ac637668d7b9")

    add_deps("mapbox_geometry")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                mapbox::geometry::polygon<double> polygon;
                mapbox::geometry::point<double> p = mapbox::polylabel(polygon, 1.0);
            }
        ]]}, {configs = {languages = "c++14"}, includes = {"mapbox/polylabel.hpp"}}))
    end)
