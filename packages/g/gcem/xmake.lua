package("gcem")

    set_kind("library", {headeronly = true})
    set_homepage("https://www.kthohr.com/gcem.html")
    set_description("A C++ compile-time math library using generalized constant expressions")
    set_license("Apache-2.0")

    add_urls("https://github.com/kthohr/gcem/archive/refs/tags/$(version).tar.gz",
             "https://github.com/kthohr/gcem.git")
    add_versions("v1.13.1", "69a1973f146a4a5e584193af062359f50bd5b948c4175d58ea2622e1c066b99b")
    add_versions("v1.16.0", "119c742b9371c0adc7d9cd710c3cbc575459a98fb63f6be4c636215dcf8404ce")

    add_deps("cmake")
    on_install("windows", "macosx", "linux", "mingw", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                constexpr int x = 10;
                constexpr int res = gcem::factorial(x);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "gcem.hpp"}))
    end)
