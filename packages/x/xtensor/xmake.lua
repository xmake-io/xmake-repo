package("xtensor")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/xtensor-stack/xtensor/")
    set_description("Multi-dimensional arrays with broadcasting and lazy computing")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/xtensor-stack/xtensor/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xtensor-stack/xtensor.git")

    add_versions("0.25.0", "32d5d9fd23998c57e746c375a544edf544b74f0a18ad6bc3c38cbba968d5e6c7")
    add_versions("0.24.7", "0fbbd524dde2199b731b6af99b16063780de6cf1d0d6cb1f3f4d4ceb318f3106")
    add_versions("0.24.3", "3acde856b9fb8cf4e2a7b66726da541275d40ab9b002e618ad985ab97f08ca4f")
    add_versions("0.24.1", "dd1bf4c4eba5fbcf386abba2627fcb4a947d14a806c33fde82d0cc1194807ee4")
    add_versions("0.24.0", "37738aa0865350b39f048e638735c05d78b5331073b6329693e8b8f0902df713")
    add_versions("0.23.10", "2e770a6d636962eedc868fef4930b919e26efe783cd5d8732c11e14cf72d871c")

    add_configs("simd", {description = "Enable SIMD acceleration ", default = true, type = "boolean"})

    add_deps("cmake")
    add_deps("xtl ^0.7.0")

    on_load("windows", "macosx", "linux", "mingw@windows", function (package) 
        if package:config("simd") then
            package:add("deps", "xsimd ^11.0.0")
        end
    end)
    on_install("windows", "macosx", "linux", "mingw@windows", function (package)
        local configs = {"-DXTENSOR_USE_XSIMD=" .. (package:config("simd") and "ON" or "OFF")}
        import("package.tools.cmake").install(package, configs, {packagedeps = "xsimd"})
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
