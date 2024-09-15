package("munkres-algorithm")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/aaron-michaux/munkres-algorithm")
    set_description("Modern C++ implementation of Munkres (Hungarian) algorithm")
    set_license("MIT")

    add_urls("https://github.com/aaron-michaux/munkres-algorithm.git")
    add_versions("2021.04.05", "30c5fbdde1e5a9fb44fcac55b7c0e8676baaccfd")

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
