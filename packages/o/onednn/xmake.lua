package("onednn")

    set_homepage("https://oneapi-src.github.io/oneDNN/")
    set_description("oneAPI Deep Neural Network Library")
    set_license("Apache-2.0")

    add_urls("https://github.com/oneapi-src/oneDNN/archive/refs/tags/$(version).tar.gz",
             "https://github.com/oneapi-src/oneDNN.git")
    add_versions("v2.5.4", "a463ab05129e3e307333ff49d637568fa6ae1fb81742f40918b618e8ef714987")

    add_configs("shared",      {description = "Build shared library.", default = true, type = "boolean"})
    add_configs("cpu_runtime", {description = "Defines the threading runtime for CPU engines.", default = "seq", type = "string", values = {"none", "omp", "tbb", "seq", "threadpool", "dpcpp"}})
    add_configs("gpu_runtime", {description = "Defines the offload runtime for GPU engines.", default = "none", type = "string", values = {"none", "ocl", "dpcpp"}})

    add_deps("cmake")
    on_load("windows|x64", "macosx", "linux|x86_64", function (package)
        local cpu_runtime = package:config("cpu_runtime")
        if cpu_runtime == "omp" then
            package:add("deps", "openmp")
        elseif cpu_runtime == "tbb" then
            package:add("deps", "tbb")
        end
        local gpu_runtime = package:config("gpu_runtime")
        if gpu_runtime == "ocl" then
            package:add("deps", "opencl")
        end
    end)

    on_install("windows|x64", "macosx", "linux|x86_64", function (package)
        local configs = {"-DDNNL_BUILD_TESTS=OFF", "-DDNNL_BUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DDNNL_LIBRARY_TYPE=" .. (package:config("shared") and "SHARED" or "STATIC"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "oneapi/dnnl/dnnl.hpp"
            void test() {
                dnnl::engine eng(dnnl::engine::kind::cpu, 0);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
