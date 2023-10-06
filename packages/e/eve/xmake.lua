package("eve")
    set_kind("library", {headeronly = true})
    set_homepage("https://jfalcou.github.io/eve/")
    set_description("Expressive Vector Engine - SIMD in C++ Goes Brrrr")
    set_license("BSL-1.0")

    add_urls("https://github.com/jfalcou/eve/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/jfalcou/eve.git")

    add_versions("2023.02.15", "7a5fb59c0e6ef3bef3e8b36d62e138d31e7f2a9f1bdfe95a8e96512b207f84c5")

    on_install(function (package)
        print(os.filedirs("*"))
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <eve/wide.hpp>
            void test() {
                eve::wide<float> x( [](auto i, auto) { return 1.f+i; } );
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
