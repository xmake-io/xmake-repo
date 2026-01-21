package("units")
    set_kind("library", {headeronly = true})
    set_homepage("https://nholthaus.github.io/units/")
    set_description("A compile-time, header-only, dimensional analysis library built on c++14 with no dependencies.")
    set_license("MIT")

    add_urls("https://github.com/nholthaus/units/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nholthaus/units.git")

    add_versions("v3.2.0", "c1cb5a92aff3fb027dbf0a81253364b41d6b03e236425a3e8fb546e4a004285a")
    add_versions("v2.3.4", "e7c7d307408c30bfd30c094beea8d399907ffaf9ac4b08f4045c890f2e076049")
    add_versions("v2.3.3", "b1f3c1dd11afa2710a179563845ce79f13ebf0c8c090d6aa68465b18bd8bd5fc")

    add_deps("cmake")

    on_install(function (package)
        io.replace("CMakeLists.txt", "set(MAIN_PROJECT ON)", "", {plain = true})
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        local languages
        if package:version() and package:version():lt("3.0.0") then
            languages = "c++14"
        else
            languages = "c++20"
        end
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <units.h>
            #include <cassert>
            using namespace units::literals;
            void test() {
                constexpr auto deg1 = 90_deg;
                constexpr auto deg2 = 60_deg;
            
                assert(deg1 > deg2);
                assert(deg1 + deg2 == 150_deg);
            }
        ]]}, {configs = {languages = languages}}))
    end)
