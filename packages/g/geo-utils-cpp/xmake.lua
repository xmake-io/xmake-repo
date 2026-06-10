package("geo-utils-cpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/gistrec/geo-utils-cpp")
    set_description("Header-only C++17 library for spherical (lat/lng) geometry on Earth coordinates: distance, bearing, polygon area, point-in-polygon, and path proximity.")
    set_license("Apache-2.0")

    add_urls("https://github.com/gistrec/geo-utils-cpp/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/gistrec/geo-utils-cpp.git")

    add_versions("1.0.2", "be01e145e38341544ba283ebd7ca9896e9b488659167b72ce662960fe4d58bb4")
    add_versions("1.0.1", "2594b5dd736dab3ee99dc586dd326f699b90243b6074df582a32547f90b82a08")

    on_install(function (package)
        os.cp("include/geo", package:installdir("include"))
        os.cp("LICENSE", package:installdir("share", package:name()))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                geo::LatLng a{0.0, 0.0};
                geo::LatLng b{1.0, 1.0};
                volatile double d = geo::distance_between(a, b);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "geo/geo.hpp"}))
    end)
