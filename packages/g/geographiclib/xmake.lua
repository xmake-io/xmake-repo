package("geographiclib")
    
    set_homepage("https://geographiclib.sourceforge.io/C++/doc/index.html")
    set_description("GeographicLib is a small C++ library for geodesic and rhumb line calculations and conversions between geographic, UTM, UPS, MGRS, geocentric")
    set_license("MIT License")

    add_urls("https://sourceforge.net/projects/geographiclib/files/distrib-C++/GeographicLib-$(version).zip")
    add_versions("2.1.1", "7887143ae2a6cae08f14f2018508d5a1636273f7f935b1a17d74b56b0252c341")
    
    add_deps("cmake")
    
    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DBUILD_BOTH_LIBS=OFF", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <GeographicLib/Geodesic.hpp>
 
            using namespace GeographicLib;
 
            void test() {
                const Geodesic& geod = Geodesic::WGS84();
                double
                    lat1 = 40.6, lon1 = -73.8, // JFK Airport
                    lat2 = 51.6, lon2 = -0.5;  // LHR Airport
                double s12;
                geod.Inverse(lat1, lon1, lat2, lon2, s12);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "GeographicLib/Geodesic.hpp"}))
    end)