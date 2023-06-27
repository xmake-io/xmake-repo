package("ceres-solver")

    set_homepage("http://ceres-solver.org/")
    set_description("Ceres Solver is an open source C++ library for modeling and solving large, complicated optimization problems.")
    
    add_urls("http://ceres-solver.org/ceres-solver-$(version).tar.gz")
    add_versions("2.0.0", "10298a1d75ca884aa0507d1abb0e0f04800a92871cd400d4c361b56a777a7603")
    add_versions("2.1.0", "f7d74eecde0aed75bfc51ec48c91d01fe16a6bf16bce1987a7073286701e2fc6")

    add_configs("blas",        {description = "Choose BLAS library to use.", default = "openblas", type = "string", values = {"mkl", "openblas"}})
    add_configs("suitesparse", {description = "Enable SuiteSparse.", default = true, type = "boolean"})

    add_deps("cmake", "eigen", "glog", "gflags")
    on_load("windows", "linux", "macosx", function (package)
        if package:config("suitesparse") then
            package:add("deps", "suitesparse", {configs = {blas = package:config("blas")}})
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DBUILD_DOCUMENTATION=OFF", "-DBUILD_EXAMPLES=OFF", "-DBUILD_BENCHMARKS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DMSVC_USE_STATIC_CRT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        table.insert(configs, "-DSUITESPARSE=" .. (package:config("suitesparse") and "ON" or "OFF"))
        table.insert(configs, "-DCXSPARSE=" .. (package:config("suitesparse") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("ceres::Problem", {configs = {languages = "c++14"}, includes = "ceres/ceres.h"}))
    end)
