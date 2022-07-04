package("mapbox_earcut")

    set_homepage("https://github.com/mapbox/earcut.hpp")
    set_description("A C++ port of earcut.js, a fast, header-only polygon triangulation library.")
    set_license("ISC")

    add_urls("https://github.com/mapbox/earcut.hpp/archive/refs/tags/v$(version).zip",
             "https://github.com/mapbox/earcut.hpp.git")
    add_versions("2.2.3", "010d2fe35938744960dcc0b25076eb541b07bb314a92afbcab14f7f887ceb98d")
    add_patches("2.2.3", path.join(os.scriptdir(), "patches", "2.2.3", "mingw.patch"), "2128177fc505a9c8229d12406c6d7335ea7e5cf0a04e448a7496d185bda9aa5a")

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
