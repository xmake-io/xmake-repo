package("flashlight")
    set_homepage("https://github.com/flashlight/flashlight")
    set_description("A C++ standalone library for machine learning.")
    set_license("MIT")

    add_urls("https://github.com/flashlight/flashlight/archive/refs/tags/$(version).tar.gz",
             "https://github.com/flashlight/flashlight.git")
    add_versions("v0.4.0", "bd33e8b9e39109905c682d549411edc748302d70bea11abb161b32462a9c22e9")
    add_versions("v0.3.2", "6557f65ef2fbacc867bb6721d9134d0bc15d29e7413cbce0ae5e28d857164029")

    add_configs("core",        {description = "Build flashlight core.", default = true, type = "boolean"})
    add_configs("arrayfire",   {description = "Build ArrayFire tensor backend.", default = true, type = "boolean"})
    add_configs("contrib",     {description = "Build and link additional flashlight contrib assets.", default = true, type = "boolean"})
    add_configs("distributed", {description = "Build and link a distributed backend with flashlight.", default = true, type = "boolean"})
    add_configs("backend",     {description = "Backend with which to build flashlight.", default = "cpu", type = "string", values = {"cpu", "cuda", "opencl"}})
    add_configs("profiling",   {description = "Enable profiling with Flashlight.", default = false, type = "boolean"})
    add_configs("all_libs",    {description = "Build all flashlight libraries.", default = false, type = "boolean"})

    local libs = {"set", "sequence", "audio", "common", "text"}
    for _, lib in ipairs(libs) do
        add_configs("lib_" .. lib, {description = "Build flashlight " .. lib .. " library.", default = nil, type = "boolean"})
    end

    add_configs("all_pkgs",    {description = "Build all flashlight packages.", default = false, type = "boolean"})

    local pkgs = {"runtime", "vision", "text", "speech"}
    for _, pkg in ipairs(pkgs) do
        add_configs("pkg_" .. pkg, {description = "Build flashlight " .. pkg .. " library.", default = nil, type = "boolean"})
    end

    add_configs("cuda",  {description = "Use CUDA in flashlight libraries build.", default = true, type = "boolean"})
    add_configs("kenlm", {description = "Use KenLM in flashlight libraries build.", default = true, type = "boolean"})
    add_configs("mkl",   {description = "Use MKL in flashlight libraries build.", default = true, type = "boolean"})
    
    add_configs("openblas",  {description = "Use OpenBLAS instead of MKL.", default = false, type = "boolean"})
    add_configs("cublas",    {description = "Use CUBLAS instead of MKL.", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("cereal")
    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        local cuda_utils = {}
        
        -- flahslight core
        if package:config("core") then
            if package:config("backend") == "cpu" then
                package:add("deps", "onednn 2.5")
                package:add("defines", "FL_BACKEND_CPU=1")
            else
                package:add("defines", "FL_BACKEND_CPU=0")
            end
            if package:config("backend") == "cuda" then
                package:add("deps", "nvtx")
                package:add("defines", "FL_BACKEND_CUDA=1", "NO_CUDNN_DESTROY_HANDLE")
                table.insert(cuda_utils, "cudnn")
            else
                package:add("defines", "FL_BACKEND_CUDA=0")
            end
            if package:config("backend") == "opencl" then
                package:add("defines", "FL_BACKEND_OPENCL=1")
            else
                package:add("defines", "FL_BACKEND_OPENCL=0")
            end
            if package:config("profiling") then
                package:add("defines", "FL_BUILD_PROFILING=1")
            else
                package:add("defines", "FL_BUILD_PROFILING=0")
            end
            if package:config("arrayfire") then
                package:add("deps", "arrayfire")
                package:add("defines", "FL_USE_ARRAYFIRE=1")
            else
                package:add("defines", "FL_USE_ARRAYFIRE=0")
            end
            if package:config("distributed") then
                package:add("deps", "mpich")
                if package:config("backend") == "cuda" then
                    package:add("defines", "NO_NCCL_COMM_DESTROY_HANDLE")
                else
                    package:add("deps", "gloo", {configs = {mpi = true}})
                end
            end
        else
            package:config_set("contrib", false)
            package:config_set("distributed", false)
            package:config_set("profiling", false)
            package:config_set("arrayfire", false)
        end

        -- flashlight library dependencies
        if package:config("mkl") then
            package:add("deps", "mkl")
            package:add("defines", "FL_LIBRARIES_USE_MKL")
        elseif package:config("openblas") then
            package:add("deps", "openblas")
        elseif package:config("cublas") then
            table.insert(cuda_utils, "cublas")
        end
        if package:config("kenlm") then
            package:add("defines", "FL_LIBRARIES_USE_KENLM")
            package:add("deps", "kenlm")
        end

        -- flashlight libraries
            if package:config("all_libs") then
            for _, lib in ipairs(libs) do
                if package:config("lib_" .. lib) ~= nil then
                    package:config_set("lib_" .. lib, true)
                end
            end
        end
        if package:config("lib_audio") then
            package:add("deps", "fftw", "openmp")
        end
        if package:config("lib_text") and package:config("kenlm") then
            package:add("defines", "KENLM_MAX_ORDER=6")
        end

        -- flashlight packages
        if package:config("all_pkgs") then
            for _, lib in ipairs(libs) do
                if package:config("pkg_" .. lib) ~= nil then
                    package:config_set("pkg_" .. lib, true)
                end
            end
        end
        if package:config("pkg_runtime") then
            package:add("deps", "glog", "gflags")
        end
        if package:config("pkg_speech") then
            package:add("deps", "libsndfile")
        end
        if package:config("pkg_vision") then
            package:add("deps", "stb")
        end

        -- flashlight backend
        if package:config("backend") == "opencl" then
            package:add("deps", "opencl", "opencl-headers")
        end
        if package:config("backend") == "cuda" then
            package:add("deps", "cuda", {configs = {utils = cuda_utils}})
        else
            package:config_set("cuda", false)
            package:config_set("cublas", false)
        end
        if package:config("cuda") then
            package:add("defines", "FL_LIBRARIES_USE_CUDA")
        end
    end)

    on_install("linux|x86_64", function (package)
        local configs = {
            "-DFL_BUILD_TESTS=OFF",
            "-DFL_BUILD_EXAMPLES=OFF",
            "-DFL_BUILD_STANDALONE=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DFL_BUILD_CORE=" .. (package:config("core") and "ON" or "OFF"))
        table.insert(configs, "-DFL_BUILD_CONTRIB=" .. (package:config("contrib") and "ON" or "OFF"))
        table.insert(configs, "-DFL_BUILD_DISTRIBUTED=" .. (package:config("distributed") and "ON" or "OFF"))
        table.insert(configs, "-DFL_BUILD_PROFILING=" .. (package:config("profiling") and "ON" or "OFF"))
        table.insert(configs, "-DFL_USE_ARRAYFIRE=" .. (package:config("arrayfire") and "ON" or "OFF"))
        table.insert(configs, "-DFL_BACKEND=" .. package:config("backend"):upper())
        for _, lib in ipairs(libs) do
            if package:config("lib_" .. lib) then
                table.insert(configs, ("-DFL_BUILD_LIB_%s=ON"):format(lib:upper()))
            end
        end
        for _, pkg in ipairs(pkgs) do
            if package:config("pkg_" .. pkg) then
                table.insert(configs, ("-DFL_BUILD_PKG_%s=ON"):format(lib:upper()))
            end
        end
        for _, lib in ipairs({"cuda", "kenlm", "mkl"}) do
            if package:config(lib) then
                table.insert(configs, ("-DFL_LIBRARIES_USE_%s=ON"):format(lib:upper()))
            end
        end
        io.replace("flashlight/fl/autograd/CMakeLists.txt", "DNNL 2.0 CONFIG", "DNNL", {plain = true})
        io.replace("CMakeLists.txt", "find_package(cereal)", [[
            find_package(PkgConfig REQUIRED)
            pkg_check_modules(cereal REQUIRED cereal)
            include_directories(${cereal_INCLUDE_DIRS})
        ]], {plain = true})
        io.replace("CMakeLists.txt", "target_link_libraries(flashlight PRIVATE cereal)", "", {plain = true})
        io.replace("flashlight/fl/common/Logging.cpp", "#include <utility>", "#include <utility>\n#include <array>", {plain = true})
        io.replace("flashlight/fl/tensor/TensorBase.h", "#include <vector>", "#include <vector>\n#include <cstdint>", {plain = true})
        io.replace("flashlight/fl/tensor/TensorBase.cpp", "#include <utility>", "#include <utility>\n#include <algorithm>", {plain = true})

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                fl::init();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "flashlight/fl/flashlight.h"}))
    end)
