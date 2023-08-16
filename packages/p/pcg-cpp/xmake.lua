package("pcg-cpp")
    set_kind("library", {headeronly = true})
    set_homepage("http://www.pcg-random.org")
    set_description("PCG — C++ Implementation")
    set_license("Apache-2.0")

    add_urls("https://github.com/imneme/pcg-cpp.git")
    add_versions("2022.04.09", "428802d1a5634f96bcd0705fab379ff0113bcf13")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <random>
            #include <pcg_random.hpp>
            void test() {
                pcg_extras::seed_seq_from<std::random_device> seed_source;
                pcg32 rng(seed_source);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
