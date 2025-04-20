package("enoki")

    set_homepage("https://github.com/mitsuba-renderer/enoki")
    set_description("Enoki: structured vectorization and differentiation on modern processor architectures")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/mitsuba-renderer/enoki.git")
    add_versions("2024.04.19", "63a5f4c0a35a8513a39393a9ee92646ce44a386e")

    add_configs("shared", {description = "Build shared library", default = true, type = "boolean", readonly = true})
    add_configs("cuda", {description = "Build Enoki CUDA library", default = false, type = "boolean"})
    add_configs("cudacc", {description = "CUDA compute capability", default = "75", type = "string", values = {"35", "50", "52", "60", "61", "70", "75", "80", "86", "89", "90"}})
    add_configs("autodiff", {description = "Build Enoki automatic differentation library", default = false, type = "boolean"})
    add_configs("python", {description = "Build pybind11 interface to CUDA & automatic differentiation libraries", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
        if package:config("python") then
            package:add("deps", "python 3.x")
        end
        if package:config("cuda") or package:config("autodiff") then
            package:add("deps", "cmake")
        else
            package:set("kind", "library", {headeronly = true})
        end
    end)

    on_install("windows", "macosx", "linux", "mingw", function (package)
        os.cp("include/enoki", package:installdir("include"))
        if package:config("cuda") or package:config("autodiff") then
            local configs = {}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DENOKI_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
            if package:config("cuda") then
                table.insert(configs, "-DENOKI_CUDA_COMPUTE_CAPABILITY=" .. package:config("cudacc"))
            end
            table.insert(configs, "-DENOKI_AUTODIFF=" .. (package:config("autodiff") and "ON" or "OFF"))
            table.insert(configs, "-DENOKI_PYTHON=" .. (package:config("python") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #ifndef _USE_MATH_DEFINES
            #define _USE_MATH_DEFINES
            #endif
            #include <enoki/array.h>
            void test() {
                enoki::Array<int, 4> idx(1, 2, 3, 4);
                using MyFloat = enoki::Array<float, 4>;
                MyFloat a = enoki::zero<MyFloat>();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
