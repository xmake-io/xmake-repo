package("xtensor")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/xtensor-stack/xtensor/")
    set_description("Multi-dimensional arrays with broadcasting and lazy computing")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/xtensor-stack/xtensor/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xtensor-stack/xtensor.git")

    add_versions("0.27.1", "117c192ae3b7c37c0156dedaa88038e0599a6b264666c3c6c2553154b500fe23")
    add_versions("0.27.0", "9ca1743048492edfcc841bbe01f58520ff9c595ec587c0e7dc2fc39deeef3e04")
    add_versions("0.26.0", "f5f42267d850f781d71097b50567a480a82cd6875a5ec3e6238555e0ef987dc6")
    add_versions("0.25.0", "32d5d9fd23998c57e746c375a544edf544b74f0a18ad6bc3c38cbba968d5e6c7")
    add_versions("0.24.7", "0fbbd524dde2199b731b6af99b16063780de6cf1d0d6cb1f3f4d4ceb318f3106")
    add_versions("0.24.3", "3acde856b9fb8cf4e2a7b66726da541275d40ab9b002e618ad985ab97f08ca4f")
    add_versions("0.24.1", "dd1bf4c4eba5fbcf386abba2627fcb4a947d14a806c33fde82d0cc1194807ee4")
    add_versions("0.24.0", "37738aa0865350b39f048e638735c05d78b5331073b6329693e8b8f0902df713")
    add_versions("0.23.10", "2e770a6d636962eedc868fef4930b919e26efe783cd5d8732c11e14cf72d871c")

    add_patches("0.25.0", "patches/0.25.0/clang19_build.patch", "b40ef789b39dad40d8f97b73793a5d0377e6165f99a49a8fddde45ff66ed87a2")

    add_configs("simd", {description = "Enable SIMD acceleration ", default = true, type = "boolean"})
    add_configs("tbb", {description = "Enable parallelization using intel TBB", default = false, type = "boolean"})
    add_configs("openmp", {description = "Enable parallelization using OpenMP", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        local version = package:version()
        if version and version:ge("0.26.0") then
            package:add("deps", "xtl ^0.8.0")
        else
            package:add("deps", "xtl ^0.7.0")
        end
        if package:config("simd") then
            if version and version:ge("0.26.0") then
                package:add("deps", "xsimd ^13.2.0")
            else
                package:add("deps", "xsimd ^11.0.0")
            end
        end
        if package:config("tbb") then
            package:add("deps", "tbb")
        end
        if package:config("openmp") then
            package:add("deps", "openmp")
        end
    end)

    on_install("windows", "macosx", "linux", "mingw@windows", function (package)
        local configs = {}
        table.insert(configs, "-DXTENSOR_USE_XSIMD=" .. (package:config("simd") and "ON" or "OFF"))
        table.insert(configs, "-DXTENSOR_USE_TBB=" .. (package:config("tbb") and "ON" or "OFF"))
        table.insert(configs, "-DXTENSOR_USE_OPENMP=" .. (package:config("openmp") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = "xsimd"})
    end)

    on_test(function (package)
        local version = package:version()
        local includes, languages
        if version and version:ge("0.26.0") then
            if version:ge("0.27.0") then
                languages = "c++20"
            else
                languages = "c++17"
            end
            includes = {"xtensor/containers/xarray.hpp", "xtensor/views/xview.hpp"}
        else
            languages = "c++14"
            includes = {"xtensor/xarray.hpp", "xtensor/xview.hpp"}
        end
        assert(package:check_cxxsnippets({test = [[
            void test() {
                xt::xarray<double> arr1{{1.0,2.0,3.0},{2.0,5.0,7.0},{2.0,5.0,7.0}};
                xt::xarray<double> arr2{5.0,6.0,7.0};
                xt::xarray<double> res = xt::view(arr1, 1) + arr2;
            }
        ]]}, {configs = {languages = languages}, includes = includes}))
    end)
