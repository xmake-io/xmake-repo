package("gcem")

    set_kind("library", {headeronly = true})
    set_homepage("https://www.kthohr.com/gcem.html")
    set_description("A C++ compile-time math library using generalized constant expressions")
    set_license("Apache-2.0")

    add_urls("https://github.com/kthohr/gcem/archive/refs/tags/$(version).tar.gz",
             "https://github.com/kthohr/gcem.git")
    add_versions("v1.18.0", "8e71a9f5b62956da6c409dda44b483f98c4a98ae72184f3aa4659ae5b3462e61")
    add_versions("v1.17.0", "74cc499e2db247c32f1ce82fc22022d22e0f0a110ecd19281269289a9e78a6f8")
    add_versions("v1.13.1", "69a1973f146a4a5e584193af062359f50bd5b948c4175d58ea2622e1c066b99b")
    add_versions("v1.16.0", "119c742b9371c0adc7d9cd710c3cbc575459a98fb63f6be4c636215dcf8404ce")

    add_deps("cmake")
    on_install(function (package)
        local configs = {"-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                constexpr int x = 10;
                constexpr int res = gcem::factorial(x);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "gcem.hpp"}))
    end)
