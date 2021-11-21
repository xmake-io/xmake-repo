package("xtensor")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/xtensor-stack/xtensor/")
    set_description("Multi-dimensional arrays with broadcasting and lazy computing")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/xtensor-stack/xtensor/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xtensor-stack/xtensor.git")
    add_versions("0.23.10", "2e770a6d636962eedc868fef4930b919e26efe783cd5d8732c11e14cf72d871c")
    add_versions("0.24.0", "37738aa0865350b39f048e638735c05d78b5331073b6329693e8b8f0902df713")

    add_deps("cmake")
    add_deps("xtl", "xsimd")
    on_install("windows", "macosx", "linux", "mingw@windows", function (package)
        import("package.tools.cmake").install(package, {"-DXTENSOR_USE_XSIMD=ON"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                xt::xarray<double> arr1{{1.0,2.0,3.0},{2.0,5.0,7.0},{2.0,5.0,7.0}};
                xt::xarray<double> arr2{5.0,6.0,7.0};
                xt::xarray<double> res = xt::view(arr1, 1) + arr2;
            }
        ]]}, {configs = {languages = "c++14"}, includes = {"xtensor/xarray.hpp", "xtensor/xview.hpp"}}))
    end)
