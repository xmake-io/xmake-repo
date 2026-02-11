package("cppad")
    set_homepage("https://cppad.readthedocs.io/")
    set_description("A C++ Algorithmic Differentiation Package: Home Page")
    set_license("EPL-2.0")

    add_urls("https://github.com/coin-or/CppAD/archive/refs/tags/$(version).tar.gz",
             "https://github.com/coin-or/CppAD.git")

    add_versions("20260000.0", "41ec617bb1e4163da381aaa5083a152e033631e9b5e135ccdc3466aaa1dc9001")

    add_deps("cmake")
    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end
    add_deps("eigen")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-Dcppad_static_lib=" .. (package:config("shared") and "false" or "true"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cppad/cppad.hpp>
            void test() {
                using CppAD::AD;
                size_t k = 5;
                CPPAD_TESTVECTOR(double) a(k);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
