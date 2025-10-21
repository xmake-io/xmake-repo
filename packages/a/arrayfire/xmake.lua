package("arrayfire")
    set_homepage("https://arrayfire.org/")
    set_description("A general purpose GPU library.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/arrayfire/arrayfire/archive/refs/tags/$(version).tar.gz",
             "https://github.com/arrayfire/arrayfire.git")
    add_versions("v3.10.0", "959f6c00a5ad6e030a178271c3976bbb06a16eef77f431ed42f4fd003c73761c")
    add_versions("v3.9.0", "ffd078dde66a1a707d049f5d2dab128e86748a92ca7204d0b3a7933a9a9904be")

    add_configs("cpu",     {description = "Build ArrayFire with a CPU backend.", default = true, type = "boolean"})
    add_configs("cuda",    {description = "Build ArrayFire with a CUDA backend.", default = false, type = "boolean"})
    add_configs("opencl",  {description = "Build ArrayFire with a OpenCL backend.", default = false, type = "boolean"})
    add_configs("oneapi",  {description = "Build ArrayFire with a oneAPI backend.", default = false, type = "boolean"})
    add_configs("unified", {description = "Build Backend-Independent ArrayFire API.", default = true, type = "boolean"})
    add_configs("cudnn",   {description = "Use cuDNN for convolveNN functions.", default = false, type = "boolean"})
    add_configs("forge",   {description = "Forge libs are not built by default as it is not link time dependency.", default = false, type = "boolean"})

    add_configs("nonfree",        {description = "Build ArrayFire nonfree algorithms.", default = false, type = "boolean"})
    add_configs("logging",        {description = "Build ArrayFire with logging support.", default = true, type = "boolean"})
    add_configs("stacktrace",     {description = "Add stacktraces to the error messages.", default = true, type = "boolean"})
    add_configs("kernel_to_disk", {description = "Enable caching kernels to disk.", default = true, type = "boolean"})
    add_configs("fast_math",      {description = "Use lower precision but high performance numeric optimizations.", default = true, type = "boolean"})
    add_configs("compute_lib",    {description = "Compute library for signal processing and linear algebra routines", default = "FFTW/LAPACK/BLAS", values = {"Intel-MKL", "FFTW/LAPACK/BLAS"}, type = "string"})
    add_configs("imageio",        {description = "Build ArrayFire with Image IO support.", default = false, type = "boolean"})

    add_configs("mkl_thread_layer", {description = "The thread layer to choose for MKL.", default = "TBB", type = "string", values = {"TBB", "GNU OpenMP", "Intel OpenMP", "Sequential"}})

    if is_plat("windows", "mingw", "msys", "cygwin") then
        add_configs("stacktrace_type", {description = "The type of backtrace features.", default = "Windbg", values = {"None", "Windbg"}})
    else
        add_configs("stacktrace_type", {description = "The type of backtrace features.", default = "Basic", values = {"None", "Basic", "libbacktrace", "addr2line"}})
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    if not is_subhost("windows") then
        add_deps("pkg-config")
    else
        add_deps("pkgconf")
    end

    add_deps("opengl", "opengl-headers", "glad", "span-lite", "clblast", "fmt")
    add_deps("spdlog", {configs = {header_only = false}})
    add_deps("boost", {configs = {filesystem = false, stacktrace = true}})
    on_load(function (package)
        if package:config("cudnn") then
            package:config_set("cuda", true)
        end
        if package:config("cuda") then
            package:add("deps", "cuda", {configs = {utils = {"cusolver", "cudnn", "cufft", "cublas", "culibos", "cusparse", "nvrtc"}}})
        end
        if package:config("opencl") then
            package:add("deps", "opencl", "opencl-headers")
        end
        if package:config("imageio") then
            package:add("deps", "freeimage")
            package:add("defines", "WITH_FREEIMAGE")
        end
        if package:config("compute_lib") == "Intel-MKL" then
            package:add("deps", "mkl")
            if package:is_arch("x64", "x86_64", "arm64", "arm64ec", "arm64-v8a") then
                package:add("defines", "AF_MKL_INTERFACE_SIZE=8")
            else
                package:add("defines", "AF_MKL_INTERFACE_SIZE=4")
            end
        else
            package:add("deps", "fftw", {configs = {precisions = {"float", "double"}}})
            package:add("deps", "lapack")
        end
        local mkl_thread_layer_map = {
            Sequential = "0",
            ["GNU OpenMP"] = "1",
            ["Intel OpenMP"] = "2",
            TBB = "3"
        }
        local layer_val = mkl_thread_layer_map[package:config("mkl_thread_layer")] or "3"
        package:add("defines", "AF_MKL_THREAD_LAYER=" .. layer_val)
    end)

    -- the lapack dep in xrepo only supports linux :(
    on_install("linux", function (package)
        io.replace("CMakeLists.txt", "find_package(BLAS)", "pkg_check_modules(BLAS blas)", {plain = true})
        io.replace("CMakeLists.txt", "find_package(LAPACK)", "pkg_check_modules(LAPACK lapack)\nlink_directories(${LAPACK_LIBRARY_DIRS})", {plain = true})
        io.replace("src/backend/common/deterministicHash.cpp", "#include <numeric>", "#include <numeric>\n#include <cstdint>", {plain = true})
        io.replace("src/backend/common/ArrayFireTypesIO.hpp", "auto format(const arrayfire::common::Version& ver, FormatContext& ctx)", "auto format(const arrayfire::common::Version& ver, FormatContext& ctx) const", {plain = true})
        io.replace("src/backend/common/ArrayFireTypesIO.hpp", "bool show_", "mutable bool show_", {plain = true})
        local configs = {
            "-DAF_WITH_EXTERNAL_PACKAGES_ONLY=ON",
            "-DAF_BUILD_DOCS=OFF",
            "-DAF_BUILD_EXAMPLES=OFF",
            "-DBUILD_TESTING=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DAF_BUILD_CPU=" .. (package:config("cpu") and "ON" or "OFF"))
        table.insert(configs, "-DAF_BUILD_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
        table.insert(configs, "-DAF_BUILD_OPENCL=" .. (package:config("opencl") and "ON" or "OFF"))
        table.insert(configs, "-DAF_BUILD_ONEAPI=" .. (package:config("oneapi") and "ON" or "OFF"))
        table.insert(configs, "-DAF_BUILD_UNIFIED=" .. (package:config("unified") and "ON" or "OFF"))
        table.insert(configs, "-DAF_WITH_CUDNN=" .. (package:config("cudnn") and "ON" or "OFF"))
        table.insert(configs, "-DAF_BUILD_FORGE=" .. (package:config("forge") and "ON" or "OFF"))
        table.insert(configs, "-DAF_WITH_NONFREE=" .. (package:config("nonfree") and "ON" or "OFF"))
        table.insert(configs, "-DAF_WITH_LOGGING=" .. (package:config("logging") and "ON" or "OFF"))
        table.insert(configs, "-DAF_WITH_STACKTRACE=" .. (package:config("stacktrace") and "ON" or "OFF"))
        table.insert(configs, "-DAF_CACHE_KERNELS_TO_DISK=" .. (package:config("kernel_to_disk") and "ON" or "OFF"))
        table.insert(configs, "-DAF_WITH_FAST_MATH=" .. (package:config("fast_math") and "ON" or "OFF"))
        table.insert(configs, "-DAF_COMPUTE_LIBRARY=" .. package:config("compute_lib"))
        table.insert(configs, "-DAF_STACKTRACE_TYPE=" .. package:config("stacktrace_type"))
        if package:dep("freeimage") then
            if not package:dep("freeimage"):config("shared") then
                table.insert(configs, "-DAF_WITH_STATIC_FREEIMAGE=ON")
                package:add("defines", "FREEIMAGE_STATIC")
            else
                table.insert(configs, "-DAF_WITH_STATIC_FREEIMAGE=OFF")
            end
        end
        if package:dep("mkl") then
            table.insert(configs, "-DAF_WITH_STATIC_MKL=" .. (package:dep("mkl"):config("shared") and "OFF" or "ON"))
        end

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace af;
            void test() {
                array A = randu(5, 3, f32);
                af_print(A);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "arrayfire.h"}))
    end)
