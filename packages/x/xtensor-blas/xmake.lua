package("xtensor-blas")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/xtensor-stack/xtensor-blas/")
    set_description("BLAS extension to xtensor")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/xtensor-stack/xtensor-blas/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xtensor-stack/xtensor-blas.git")
    add_versions("0.23.0", "3411f56d243b92a22fe3a259bc8b414d851ab167b9d30700a1776c9908e0b595")
    add_versions("0.22.0", "4cda5ed77ba4b78fdd913a70ccfdf53d86185f61da5713f9edd935488d5db828")
    add_versions("0.21.0", "89ce6eceb47018f3b557945468502593e0bf0e5a816548aad8ac22247c8198b1")
    add_versions("0.20.0", "272f5d99bb7511a616bfe41b13a000e63de46420f0b32a25fa4fb935b462c7ff")
    add_versions("0.19.1", "c77cc4e2297ebd22d0d1c6e8d0a6cf0975176afa8cb99dbfd5fb2be625a0248f")

    add_configs("vendor", {description = "Set BLAS vendor.", default = "openblas", type = "string", values = {"mkl", "openblas"}})

    add_deps("cmake")

    if on_check then
        on_check("windows", function (package)
            if package:is_arch("arm64") then
                raise("package(xtensor-blas): unsupport windows|arm64")
            end
        end)
    end

    on_load("windows", "linux", function (package)
        package:add("deps", package:config("vendor"))
        local version = package:version()
        if version and version:le("0.19.2") then
            package:add("deps", "xtensor <0.24")
        elseif version and version:le("0.20.0") then
            package:add("deps", "xtensor <0.25")
        elseif version and version:le("0.21.0") then
            package:add("deps", "xtensor <0.26")
        elseif version and version:le("0.22.0") then
            package:add("deps", "xtensor >=0.26 <0.27")
        else
            package:add("deps", "xtensor >=0.27")
        end
    end)

    on_install("windows", "linux", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        local languages = "c++14"
        local version = package:version()
        if version and version:ge("0.23.0") then
            languages = "c++20"
        elseif version and version:ge("0.22.0") then
            languages = "c++17"
        end
        assert(package:check_cxxsnippets({test = [[
            #include <xtensor-blas/xlinalg.hpp>
            void test() {
                xt::xarray<double> t1arg_0 = {{0, 1, 2},
                                              {3, 4, 5},
                                              {6, 7, 8}};
                auto t1res = xt::linalg::matrix_power(t1arg_0, 2);
            }
        ]]}, {configs = {languages = languages}}))
    end)
