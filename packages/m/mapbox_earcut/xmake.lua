package("mapbox_earcut")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/mapbox/earcut.hpp")
    set_description("A C++ port of earcut.js, a fast, header-only polygon triangulation library.")
    set_license("ISC")

    add_urls("https://github.com/mapbox/earcut.hpp/archive/refs/tags/v$(version).zip",
             "https://github.com/mapbox/earcut.hpp.git")
    add_versions("2.2.3", "010d2fe35938744960dcc0b25076eb541b07bb314a92afbcab14f7f887ceb98d")
    add_patches("2.2.3", path.join(os.scriptdir(), "patches", "2.2.3", "mingw.patch"), "ac6ceb3d494d5a553936f6845c2df41d567614e33e389f47fe1520d6070a30e0")

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
