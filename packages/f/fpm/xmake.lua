package("fpm")
    set_kind("library", {headeronly = true})
    set_homepage("https://mikelankamp.github.io/fpm")
    set_description("C++ header-only fixed-point math library")
    set_license("MIT")

    add_urls("https://github.com/MikeLankamp/fpm.git")

    add_versions("2024.09.06", "464cf63a5b1a4537e2b86014b2b72f4cfbdfd779")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                fpm::fixed_16_16 x;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "fpm/fixed.hpp"}))
    end)
