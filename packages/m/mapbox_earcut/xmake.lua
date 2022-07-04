package("mapbox_earcut")

    set_homepage("https://github.com/mapbox/earcut.hpp")
    set_description("A C++ port of earcut.js, a fast, header-only polygon triangulation library.")
    set_license("ISC")

    add_urls("https://github.com/mapbox/earcut.hpp/archive/refs/tags/v$(version).zip",
             "https://github.com/mapbox/earcut.hpp.git")
    add_versions("2.2.3", "010d2fe35938744960dcc0b25076eb541b07bb314a92afbcab14f7f887ceb98d")
    add_patches("2.2.3", path.join(os.scriptdir(), "patches", "2.2.3", "mingw.patch"), "20a83bb8fdbc98f5ef034172d7b71120c59899bca0c81e9ccaee6d31ecf760d5")

    on_install(function (package)
        os.cp("include/mapbox", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <mapbox/earcut.hpp>
            #include <vector>
            #include <array>

            using N = uint32_t;
            using PolyPoint2D = std::array<double, 2>;

            void test () {
                std::vector<std::vector<PolyPoint2D> > polygons2d;
                mapbox::earcut<N>(polygons2d);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "mapbox/earcut.hpp"}))
    end)
