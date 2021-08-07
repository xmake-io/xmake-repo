package("xtensor-blas")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/xtensor-stack/xtensor-blas/")
    set_description("BLAS extension to xtensor")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/xtensor-stack/xtensor-blas/archive/refs/tags/$(version).tar.gz")
    add_versions("0.19.1", "c77cc4e2297ebd22d0d1c6e8d0a6cf0975176afa8cb99dbfd5fb2be625a0248f")

    add_configs("vendor", {description = "Set BLAS vendor.", default = "openblas", type = "string", values = {"mkl", "openblas"}})

    add_deps("cmake")
    add_deps("xtensor")
    on_load("windows", "linux", function (package)
        package:add("deps", package:config("vendor"))
    end)

    on_install("windows", "linux", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <xtensor/xarray.hpp>
            #include <xtensor-blas/xlinalg.hpp>
            void test() {
                xt::xarray<double> t1arg_0 = {{0, 1, 2},
                                              {3, 4, 5},
                                              {6, 7, 8}};
                auto t1res = xt::linalg::matrix_power(t1arg_0, 2);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
