package("digestpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/kerukuro/digestpp")
    set_description("C++11 header-only message digest library")
    set_license("MIT")

    add_urls("https://github.com/kerukuro/digestpp.git")
    add_versions("2023.11.8", "ebb699402c244e22c3aff61d2239bcb2e87b8ef8")

    on_install(function (package)
        os.cp("*", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include "digestpp.hpp"
            void test() {
                std::cout << digestpp::blake2b().absorb("The quick brown fox jumps over the lazy dog").hexdigest();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
