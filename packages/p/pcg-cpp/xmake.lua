package("pcg-cpp")
    set_kind("library", {headeronly = true})
    set_homepage("http://www.pcg-random.org")
    set_description("PCG — C++ Implementation")
    set_license("Apache-2.0")

    add_urls("https://github.com/imneme/pcg-cpp.git")
    add_versions("2022.04.09", "428802d1a5634f96bcd0705fab379ff0113bcf13")
    add_patches("2022.04.09", "patches/2022.04.09/msvc-arm64.patch", "6923b80da69c531d0f4e3c0f736dced7e096311d5f3c00681a55ec63b2bb3591")

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
