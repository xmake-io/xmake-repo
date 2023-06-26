package("units")
    set_kind("library", {headeronly = true})
    set_homepage("https://nholthaus.github.io/units/")
    set_description("A compile-time, header-only, dimensional analysis library built on c++14 with no dependencies.")

    add_urls("https://github.com/nholthaus/units/archive/refs/tags/$(version).tar.gz", "https://github.com/nholthaus/units.git")
    add_versions("v2.3.3", "b1f3c1dd11afa2710a179563845ce79f13ebf0c8c090d6aa68465b18bd8bd5fc")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <units.h>
            #include <cassert>
            static void test() {
                constexpr units::angle::degree_t deg1{90};
                constexpr units::angle::degree_t deg2{60};
            
                assert(deg1 > deg2);
                assert(deg1 + deg2 == units::angle::degree_t{150});
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
