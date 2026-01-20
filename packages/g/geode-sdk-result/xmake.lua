package("geode-sdk-result")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/geode-sdk/result")
    set_description("A result class for C++.")
    set_license("BSL-1.0")

    add_urls("https://github.com/geode-sdk/result/archive/refs/tags/$(version).tar.gz",
             "https://github.com/geode-sdk/result.git")

    add_versions("v1.3.5", "62bd9cc3abe98640d673c95571eb9978434a22351dfff4efef6cfdc3f94af36a")

    if on_check then
        on_check(function (package)
            assert(package:check_cxxsnippets({test = [[
                #include <concepts>
                void test() {
                    static_assert(std::constructible_from<int, int>);
                    static_assert(std::constructible_from<double, float>);
                }
            ]]}, {configs = {languages = "c++20"}}), "package(geode-sdk-result) Require at least C++20 (supports std::constructible_from).")
        end)
    end

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace geode;
            Result<int> integerDivision(int a, int b) {
                if (b == 0) {
                    return Err("Division by zero");
                }
                return Ok(a / b);
            }
            void test() {
                int value = integerDivision(3, 2).unwrapOrDefault();
                value = integerDivision(3, 0).unwrapOr(0);
            }
        ]]}, {configs = {languages = "c++20"}, includes = "Geode/Result.hpp"}))
    end)
