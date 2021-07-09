package("catch2")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/catchorg/Catch2")
    set_description("Catch2 is a multi-paradigm test framework for C++. which also supports Objective-C (and maybe C). ")

    add_urls("https://github.com/catchorg/Catch2/archive/v$(version).zip")
    add_versions("2.13.6", "39d50f5d1819cdf2908066664d57c2cde4a4000c364ad3376ea099735c896ff4")
    add_versions("2.13.5", "728679b056dc1248cc79b3a1999ff7453f76422c68417563fc47a0ac2aaeeaef")
    add_versions("2.9.2", "dc486300de22b0d36ddba1705abb07b9e5780639d824ba172ddf7062b2a1bf8f")

    on_install(function (package)
        os.cp("single_include/catch2", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            int factorial(int number) { return number <= 1 ? number : factorial(number - 1) * number; }

            TEST_CASE("testing the factorial function") {
                CHECK(factorial(1) == 1);
                CHECK(factorial(2) == 2);
                CHECK(factorial(3) == 6);
                CHECK(factorial(10) == 3628800);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "catch2/catch.hpp", defines = "CATCH_CONFIG_MAIN "}))
    end)
