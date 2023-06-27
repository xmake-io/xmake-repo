package("mapbox_eternal")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/mapbox/eternal")
    set_description("A C++14 compile-time/constexpr map and hash map with minimal binary footprint")
    set_license("ISC")

    set_urls("https://github.com/mapbox/eternal/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mapbox/eternal.git")

    add_versions("v1.0.1", "7d799381b3786d0bd987eea75df2a81f581a64ee962e922a2f7a7d3d0c3d0421")
    add_patches("v1.0.1", path.join(os.scriptdir(), "patches", "add_cstdint.patch"), "9a3724ec903fb9d8963ac1d144228f9b5800a102857ea80199b0251f254d89b4")

    on_install(function (package)
        os.cp("include/mapbox", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
          struct Color
          {
              unsigned int r, g, b, a;
          };
          
          constexpr auto colors = mapbox::eternal::map<mapbox::eternal::string, Color>({
              { "red", { 255, 0, 0, 1 } },
              { "green", { 0, 128, 0, 1 } },
              { "yellow", { 255, 255, 0, 1 } },
              { "white", { 255, 255, 255, 1 } },
              { "black", { 0, 0, 0, 1 } }
            });
          
            void test()
            {
                colors.contains("yellow");
            }
        ]]}, {configs = {languages = "c++14"}, includes = { "mapbox/eternal.hpp"} }))
    end)
