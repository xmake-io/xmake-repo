package("doctest")

    set_kind("library", {headeronly = true})
    set_homepage("http://bit.ly/doctest-docs")
    set_description("The fastest feature-rich C++11/14/17/20 single-header testing framework for unit tests and TDD")
    set_license("MIT")

    set_urls("https://github.com/doctest/doctest/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/doctest/doctest/archive/refs/tags/$(version).tar.gz",
             "https://github.com/onqtam/doctest/archive/$(version).tar.gz",
             "https://github.com/onqtam/doctest.git")

    add_versions("2.4.11", "632ed2c05a7f53fa961381497bf8069093f0d6628c5f26286161fbd32a560186")
    add_versions("2.4.10", "d23213c415152d7aa4de99bb7c817fa29c0c03bd1a89972748579a7217fdbb8f")
    add_versions("2.4.9", "19b2df757f2f3703a5e63cee553d85596875f06d91a3333acd80a969ef210856")
    add_versions("2.4.8", "f52763630aa17bd9772b54e14b6cdd632c87adf0169455a86a49bd94abf2cd83")
    add_versions("2.3.6", "f63c3c01021ba3fb35a0702127abfaa6fc44aaefd309e2c246e62a083deffa1f")
    add_versions("2.3.1", "b3d3c6133874e3a8c8e319cab33167156b6b1d2ed1ddde08c2655193cdeb58a0")

    on_install(function (package)
        os.cp("doctest", package:installdir("include"))
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
        ]]}, {configs = {languages = "c++11"}, includes = "doctest/doctest.h", defines = "DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN"}))
    end)
