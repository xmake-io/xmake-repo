package("munkres-algorithm")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/aaron-michaux/munkres-algorithm")
    set_description("Modern C++ implementation of Munkres (Hungarian) algorithm")
    set_license("MIT")

    add_urls("https://github.com/aaron-michaux/munkres-algorithm.git")
    add_versions("2021.04.05", "30c5fbdde1e5a9fb44fcac55b7c0e8676baaccfd")

    add_patches("2021.04.05", "patches/2021.04.05/cstdint.patch", "ceca3960e7fbed9578517c1e5830e5e056d4c0bdcc250871d3277364729c78fe")

    on_install(function (package)
        os.cp("munkres.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto result = munkres_algorithm<double>(3, 3, 
                    [&](unsigned l, unsigned r) -> float {
                        return 0;
                    }
                );
            }
        ]]}, {configs = {languages = "c++14"}, includes = "munkres.hpp"}))
    end)
