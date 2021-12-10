package("xframe")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/xtensor-stack/xframe/")
    set_description("C++ multi-dimensional labeled arrays and dataframe based on xtensor")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/xtensor-stack/xframe/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xtensor-stack/xframe.git")
    add_versions("0.3.0", "1e8755b7a8b54dd8b7c7b65d99cc896e587ebf563c937f4aae1f73ad4f4c6be1")
    add_versions("0.2.0", "0149f8dd5f38a6783544abca8abaadba45bab321fdcc0db0dd8b11148e1d741f")

    add_deps("cmake")
    add_deps("xtensor", "xtl")
    on_install("windows", "macosx", "linux", "mingw@windows", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "xtensor/xrandom.hpp"
            #include "xframe/xio.hpp"
            #include "xframe/xvariable.hpp"
            void test() {
                using coordinate_type = xf::xcoordinate<xf::fstring>;
                using variable_type = xf::xvariable<double, coordinate_type>;
                using data_type = variable_type::data_type;

                data_type data = xt::eval(xt::random::rand({6, 3}, 15., 25.));
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
