package("magma")

    set_homepage("https://icl.utk.edu/magma/")
    set_description("Matrix Algebra on GPU and Multicore Architectures")
    set_license("BSD-3-Clause")

    add_urls("http://icl.utk.edu/projectsfiles/magma/downloads/magma-$(version).tar.gz")
    add_versions("2.7.1", "d9c8711c047a38cae16efde74bee2eb3333217fd2711e1e9b8606cbbb4ae1a50")

    add_patches("2.7.1", path.join(os.scriptdir(), "patches", "2.7.1", "disable_test.patch"), "a4cc8f7a19d5cce80bf358d69eedfd8642edc0b8a931c792be239b5298519835")

    add_configs("fortran",     {description = "Enable Fortran support.", default = false, type = "boolean"})
    add_configs("gpu_target",  {description = "GPU architectures to compile for.", default = "sm_50 sm_70", type = "string"})
    add_configs("blas_vendor", {description = "BLAS vendor to use.", default = "OpenBLAS", type = "string", values = {"OpenBLAS", "Intel10_64lp", "Intel10_64lp_seq", "Intel10_64ilp", "Intel10_64ilp_seq", "Generic"}})

    add_deps("cmake")
    add_deps("cuda", {system = true, configs = {utils = {"cublas", "cusparse"}}})
    add_links("magma_sparse", "magma")
    -- TODO: add AMD HIP support
    on_load("windows", "linux", function (package)
        local vendor = package:config("blas_vendor")
        if vendor == "OpenBLAS" then
            package:add("deps", "openblas")
        elseif vendor:startswith("Intel") then
            package:add("deps", "mkl")
        end
    end)

    on_install("windows", "linux", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_FORTRAN=" .. (package:config("fortran") and "ON" or "OFF"))
        table.insert(configs, "-DGPU_TARGET=" .. package:config("gpu_target"))
        table.insert(configs, "-DBLA_VENDOR=" .. package:config("blas_vendor"))
        if package:is_plat("windows") then
            import("package.tools.cmake").install(package, configs, {cxflags = "/Zc:__cplusplus"})
        else
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("magma_init", {includes = "magma_v2.h"}))
    end)
