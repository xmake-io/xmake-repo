package("ceres-solver")
    set_homepage("http://ceres-solver.org/")
    set_description("Ceres Solver is an open source C++ library for modeling and solving large, complicated optimization problems.")
    set_license("BSD-3-Clause")
    
    add_urls("http://ceres-solver.org/ceres-solver-$(version).tar.gz")
    add_versions("2.0.0", "10298a1d75ca884aa0507d1abb0e0f04800a92871cd400d4c361b56a777a7603")
    add_versions("2.1.0", "f7d74eecde0aed75bfc51ec48c91d01fe16a6bf16bce1987a7073286701e2fc6")
    add_versions("2.2.0", "48b2302a7986ece172898477c3bcd6deb8fb5cf19b3327bc49969aad4cede82d")

    add_patches("2.1.0", "patches/2.1.0/int64.patch", "1df14f30abf1a942204b408c780eabbeac0859ba5a6db3459b55c47479583c57")

    add_configs("blas", {description = "Choose BLAS library to use.", default = "openblas", type = "string", values = {"mkl", "openblas"}})
    add_configs("suitesparse", {description = "Enable SuiteSparse.", default = true, type = "boolean"})
    add_configs("cuda", {description = "Enable CUDA support.", default = false, type = "boolean"})

    add_deps("cmake", "eigen", "glog", "gflags")

    on_load(function (package)
        if package:config("suitesparse") then
            package:add("deps", "suitesparse", {configs = {blas = package:config("blas")}})
            package:add("deps", "openmp")
        end
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
    end)

    on_install("windows|x64", "windows|x86", "linux", "macosx", function (package)
        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DBUILD_DOCUMENTATION=OFF",
            "-DBUILD_EXAMPLES=OFF",
            "-DBUILD_BENCHMARKS=OFF",
            "-DCXSPARSE=OFF"
        }

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DMSVC_USE_STATIC_CRT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        table.insert(configs, "-DSUITESPARSE=" .. (package:config("suitesparse") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
        if package:config("suitesparse") then
            import("package.tools.cmake").install(package, configs, {packagedeps = {"openmp", "libomp"}})
        else
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("ceres::Problem", {configs = {languages = "c++17"}, includes = "ceres/ceres.h"}))
    end)
