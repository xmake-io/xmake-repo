package("ginkgo")
    set_homepage("https://ginkgo-project.github.io/")
    set_description("Ginkgo is a high-performance linear algebra library for manycore systems, with a focus on solution of sparse linear systems.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/ginkgo-project/ginkgo/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ginkgo-project/ginkgo.git")
    add_versions("v1.11.0", "8052c3d5994e1c996ebabe50a169deb565965da4f1c6c02e814ff0c7146c0378")
    add_versions("v1.9.0", "18271e99f81a89cf27102f9d4e84653ae7a0cc745fcda9a7ed486c455553780b")
    add_versions("v1.8.0", "421efaed1be2ef11d230b79fc68bcf7e264a2c57ae52aff6dec7bd90f8d4ae30")
    add_versions("v1.7.0", "f4b362bcb046bc53fbe2e578662b939222d0c44b96449101829e73ecce02bcb3")

    add_configs("openmp", {description = "Compile OpenMP kernels for CPU.", default = false, type = "boolean"})
    add_configs("cuda",   {description = "Compile kernels for NVIDIA GPUs.", default = false, type = "boolean"})
    add_configs("hip",    {description = "Compile kernels for AMD or NVIDIA GPUs.", default = false, type = "boolean"})
    add_configs("sycl",   {description = "Compile SYCL kernels for Intel GPUs or other SYCL enabled hardware.", default = false, type = "boolean"})
    add_configs("jacobi_full", {description = "Use all the optimizations for the CUDA Jacobi algorithm.", default = false, type = "boolean"})

    set_policy("package.cmake_generator.ninja", false)

    add_deps("cmake")

    if on_check then
        on_check("windows", function(package)
            if package:version():ge("1.10.0") and package:is_arch("x86") then
                raise("package(ginkgo >= v1.10.0): not support windows|x86")
            end
        end)
    end

    on_load("windows", "macosx", "linux", function (package)
        if package:config("openmp") then
            package:add("deps", "openmp")
        end
        if package:config("cuda") then
            package:add("deps", "cuda", {configs = {utils = {"cublas", "cusparse"}}})
        end
        if not (package:is_plat("windows") and package:config("shared")) then
            package:add("deps", "ninja")
        end
        -- TODO: add hip and sycl
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DGINKGO_BUILD_TESTS=OFF", "-DGINKGO_BUILD_EXAMPLES=OFF", "-DGINKGO_BUILD_BENCHMARKS=OFF", "-DGINKGO_BUILD_REFERENCE=ON", "-DGINKGO_BUILD_MPI=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DGINKGO_BUILD_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
        table.insert(configs, "-DGINKGO_BUILD_HIP=" .. (package:config("hip") and "ON" or "OFF"))
        table.insert(configs, "-DGINKGO_BUILD_SYCL=" .. (package:config("sycl") and "ON" or "OFF"))
        table.insert(configs, "-DGINKGO_BUILD_OMP=" .. (package:config("openmp") and "ON" or "OFF"))
        table.insert(configs, "-DGINKGO_JACOBI_FULL_OPTIMIZATIONS=" .. (package:config("jacobi_full") and "ON" or "OFF"))
        local opt = {}
        if not (package:is_plat("windows") and package:config("shared")) then
            opt.cmake_generator = "Ninja"
        end
        if package:is_plat("windows") then
            opt.cxflags = "/bigobj /Gy"
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ginkgo/ginkgo.hpp>
            void test() {
                const auto exec = gko::ReferenceExecutor::create();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
