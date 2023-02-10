package("suitesparse")

    set_homepage("https://people.engr.tamu.edu/davis/suitesparse.html")
    set_description("SuiteSparse is a suite of sparse matrix algorithms")

    add_urls("https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/$(version).tar.gz",
             "https://github.com/DrTimothyAldenDavis/SuiteSparse.git")
    add_versions("v5.10.1", "acb4d1045f48a237e70294b950153e48dce5b5f9ca8190e86c2b8c54ce00a7ee")
    add_versions("v5.12.0", "5fb0064a3398111976f30c5908a8c0b40df44c6dd8f0cc4bfa7b9e45d8c647de")
    add_versions("v5.13.0", "59c6ca2959623f0c69226cf9afb9a018d12a37fab3a8869db5f6d7f83b6b147d")

    add_patches("5.x", path.join(os.scriptdir(), "patches", "5.10.1", "msvc.patch"), "8ac61e9acfaa864a2528a14d3a7e6e86f6e6877de2fe93fdc87876737af5bf31")

    add_configs("cuda", {description = "Enable CUDA support.", default = false, type = "boolean"})
    add_configs("blas", {description = "Set BLAS vendor.", default = "openblas", type = "string", values = {"mkl", "openblas"}})
    add_configs("graphblas", {description = "Enable GraphBLAS module.", default = false, type = "boolean"})

    add_deps("metis")
    if is_plat("linux") then
        add_syslinks("m", "rt")
    end
    on_load("windows", "macosx", "linux", function (package)
        if package:config("cuda") then
            package:add("deps", "cuda", {system = true, configs = {utils = {"cublas"}}})
            package:add("links", "GPUQREngine")
            package:add("links", "SuiteSparse_GPURuntime")
        end
        if package:config("graphblas") then
            package:add("links", "GraphBLAS")
        end
        package:add("deps", package:config("blas"))
        for _, lib in ipairs({"SPQR", "UMFPACK", "LDL", "KLU", "CXSparse", "CHOLMOD", "COLAMD", "CCOLAMD", "CAMD", "BTF", "AMD", "suitesparseconfig"}) do
            package:add("links", lib)
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        local configs = {}
        configs.with_blas = package:config("blas")
        configs.with_cuda = package:config("cuda")
        configs.graphblas = package:config("graphblas")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SuiteSparse_start", {includes = "SuiteSparse_config.h"}))
    end)
