package("onednn")

    set_homepage("https://oneapi-src.github.io/oneDNN/")
    set_description("oneAPI Deep Neural Network Library")
    set_license("Apache-2.0")

    add_urls("https://github.com/oneapi-src/oneDNN/archive/refs/tags/$(version).tar.gz",
             "https://github.com/oneapi-src/oneDNN.git")
    add_versions("v3.10.2", "58a7399c86789bf3756117072ed946d764ba59dd1480f0e42efd4f9b6b7b9a64")
    add_versions("v3.10.1", "d89998bfae2f33c209e216e3d3a8d280ed6eb65a57971dfb4dcfa56beac9571b")
    add_versions("v3.10", "ba5834a1fdbb6d1c1b1c065dfd789438e7aa42c03fc52d92c02af85d78d1c75c")
    add_versions("v3.9.1", "fa44702f5979ed5ab927f7ccc1d2947adb4e6d0e58c433149465c5fc71e3bd45")
    add_versions("v3.9", "806ec963b8a89cc7555c43afbb6f5369dc9010c8cf435b85aaf708acd1a2d837")
    add_versions("v3.8.1", "4b0638061a789a1efbefdcd2e85eb257c7b432b3b6a71ba8909e19d75f50b163")
    add_versions("v3.8", "06c11b9e4d25ddaaec219f0e93f6bdbbbc27dcf8eb992f76b768a2a056a087a9")
    add_versions("v3.7.2", "21068e8cd2bf4077916bf31452eab5ac9998e620e1b22630a88f79c334857a5c")
    add_versions("v3.7.1", "580f56abe12f2bd9d628a47586b00c516d410b086d7227a800aedc4891f4e93a")
    add_versions("v3.6.2", "e79db0484dcefe2c7ff6604c295d1de2830c828941898878c80dfb062eb344d1")
    add_versions("v3.6.1", "a370e7f25dbf05c9c151878c53556f27d0cbe7a4f909747db6e4b2d245f533cb")
    add_versions("v3.6", "20c4a92cc0ae0dc19d3d2beca0e357b1d13a5a3af9890a2cc3e41a880e4a0302")
    add_versions("v3.5.3", "ddbc26c75978c5e864050f699dbefbf5bff9c0b8d2af827845708e1376471f17")
    add_versions("v3.5.2", "e6af4a8869c9a06fa0806ed8c93faa8f8a57118ba7a36a93b93a5c2285a3a49f")
    add_versions("v3.5.1", "f316368a0d8c5235d80704def93f0e8c28e08dfaa2231a3de558be0ae2b146e7")
    add_versions("v3.5", "8356aa9befde4d4ff93f1b016ac4310730b2de0cc0b8c6c7ce306690bc0d7b43")
    add_versions("v3.4.3", "b795dc07d0d83aaec531081e77d5fb2e503a143f4330eabe4f035d4117c191ae")
    add_versions("v3.4.2", "5131ac559a13daa6e2784d20ab24e4607e55aa6da973518086326a647d389425")
    add_versions("v3.4.1", "906559a25581b292352420721112e1656d21029b66e8597816f9e741fbcdeadb")
    add_versions("v3.4", "1044dc3655d18de921c98dfc61ad7f65799ba5e897063d4a56d291394e12dcf5")
    add_versions("v3.3.4", "e291fa4702f4bcfa6c8c23cb5b6599f0fefa8f23bc08edb9e15ddc5254ab7843")
    add_versions("v2.5.4", "a463ab05129e3e307333ff49d637568fa6ae1fb81742f40918b618e8ef714987")

    add_configs("shared",      {description = "Build shared library.", default = true, type = "boolean"})
    add_configs("cpu_runtime", {description = "Defines the threading runtime for CPU engines.", default = "seq", type = "string", values = {"none", "omp", "tbb", "seq", "threadpool", "dpcpp"}})
    add_configs("gpu_runtime", {description = "Defines the offload runtime for GPU engines.", default = "none", type = "string", values = {"none", "ocl", "dpcpp"}})

    add_deps("cmake")
    on_load("windows|x64", "macosx|x86_64", "linux|x86_64", function (package)
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

    on_install("windows|x64", "macosx|x86_64", "linux|x86_64", function (package)
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
