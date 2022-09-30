package("libtorch")

    set_homepage("https://pytorch.org/")
    set_description("An open source machine learning framework that accelerates the path from research prototyping to production deployment.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/pytorch/pytorch.git")
    add_versions("v1.8.0", "37c1f4a7fef115d719104e871d0cf39434aa9d56")
    add_versions("v1.8.1", "56b43f4fec1f76953f15a627694d4bba34588969")
    add_versions("v1.8.2", "e0495a7aa104471d95dc85a1b8f6473fbcc427a8")
    add_versions("v1.9.0", "d69c22dd61a2f006dcfe1e3ea8468a3ecaf931aa")
    add_versions("v1.9.1", "dfbd030854359207cb3040b864614affeace11ce")
    add_versions("v1.11.0", "bc2c6edaf163b1a1330e37a6e34caf8c553e4755")
    add_versions("v1.12.1", "664058fa83f1d8eede5d66418abff6e20bd76ca8")

    add_patches("1.9.x", path.join(os.scriptdir(), "patches", "1.9.0", "gcc11.patch"), "4191bb3296f18f040c230d7c5364fb160871962d6278e4ae0f8bc481f27d8e4b")
    add_patches("1.11.0", path.join(os.scriptdir(), "patches", "1.11.0", "gcc11.patch"), "1404b0bc6ce7433ecdc59d3412e3d9ed507bb5fd2cd59134a254d7d4a8d73012")
    -- Fix compile on macOS. Refer to https://github.com/pytorch/pytorch/pull/80916
    add_patches("1.12.1", path.join(os.scriptdir(), "patches", "1.12.1", "clang.patch"), "cdc3e00b2fea847678b1bcc6b25a4dbd924578d8fb25d40543521a09aab2f7d4")
    add_patches("1.12.1", path.join(os.scriptdir(), "patches", "1.12.1", "vs2022.patch"), "5a31b9772793c943ca752c92d6415293f7b3863813ca8c5eb9d92a6156afd21d")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean"})
    add_configs("python", {description = "Build python interface.", default = false, type = "boolean"})
    add_configs("openmp", {description = "Use OpenMP for parallel code.", default = true, type = "boolean"})
    add_configs("cuda",   {description = "Enable CUDA support.", default = false, type = "boolean"})
    add_configs("ninja",  {description = "Use ninja as build tool.", default = false, type = "boolean"})
    add_configs("blas",   {description = "Set BLAS vendor.", default = "openblas", type = "string", values = {"mkl", "openblas", "eigen"}})
    add_configs("pybind11", {description = "Use pybind11 from xrepo.", default = false, type = "boolean"})
    add_configs("protobuf-cpp", {description = "Use protobuf from xrepo.", default = false, type = "boolean"})
    if not is_plat("macosx") then
        add_configs("distributed", {description = "Enable distributed support.", default = false, type = "boolean"})
    end

    add_deps("cmake")
    add_deps("python 3.x", {kind = "binary"})

    add_includedirs("include")
    add_includedirs("include/torch/csrc/api/include")
    if is_plat("linux") then
        add_syslinks("rt")
    end

    -- enable long paths for git submodule on windows
    if is_host("windows") and set_policy then
        set_policy("platform.longpaths", true)
    end

    on_load("windows|x64", "macosx", "linux", function (package)
        if package:config("ninja") then
            package:add("deps", "ninja")
        end
        if package:config("openmp") then
            package:add("deps", "openmp")
        end
        if package:config("cuda") then
            package:add("deps", "cuda", {configs = {utils = {"nvrtc", "cudnn", "cufft", "curand", "cublas", "cudart_static"}}})
            package:add("deps", "nvtx")
        end
        if package:config("distributed") then
            package:add("deps", "libuv")
        end
        if not package:is_plat("macosx") and package:config("blas") then
            package:add("deps", package:config("blas"))
        end
        if package:config("pybind11") then
            package:add("deps", "pybind11")
        end
        if package:config("protobuf-cpp") then
            package:add("deps", "protobuf-cpp")
        end
    end)

    on_install("windows|x64", "macosx", "linux", function (package)
        import("package.tools.cmake")

        if package:is_plat("windows") then
            local vs = import("core.tool.toolchain").load("msvc"):config("vs")
            if tonumber(vs) < 2019 then
                raise("Your compiler is too old to use this library.")
            end
        end

        -- tackle link flags
        local libnames = {"torch", "torch_cpu"}
        if package:config("cuda") then
            table.insert(libnames, "torch_cuda")
        end
        table.insert(libnames, "c10")
        if package:config("cuda") then
            table.insert(libnames, "c10_cuda")
        end
        local suffix = ""
        if not package:is_plat("windows") and package:config("shared") then
            package:add("ldflags", "-Wl,-rpath," .. package:installdir("lib"))
            if package:is_plat("linux") then
                suffix = ".so"
            elseif package:is_plat("macosx") then
                suffix = ".dylib"
            end
            for _, lib in ipairs(libnames) do
                package:add("ldflags", (package:is_plat("linux") and "-Wl,--no-as-needed," or "") .. package:installdir("lib", "lib") .. lib .. suffix)
            end
        else
            for _, lib in ipairs(libnames) do
                package:add("links", lib)
            end
        end
        if not package:config("shared") then
            for _, lib in ipairs({"nnpack", "pytorch_qnnpack", "qnnpack", "XNNPACK", "caffe2_protos", "protobuf-lite", "protobuf", "protoc", "onnx", "onnx_proto", "foxi_loader", "pthreadpool", "eigen_blas", "fbgemm", "cpuinfo", "clog", "dnnl_graph", "dnnl", "mkldnn", "sleef", "asmjit", "fmt", "kineto"}) do
                package:add("links", lib)
            end
        end

        -- some patches to the third-party cmake files
        io.replace("third_party/fbgemm/CMakeLists.txt", "PRIVATE FBGEMM_STATIC", "PUBLIC FBGEMM_STATIC", {plain = true})
        -- Workaround to compile with GCC-12.
        -- Refer to [this pytorch issue](https://github.com/pytorch/pytorch/issues/77939).
        io.replace("third_party/fbgemm/CMakeLists.txt",
            'string(APPEND CMAKE_CXX_FLAGS " -Werror")',
            'string(APPEND CMAKE_CXX_FLAGS " -Werror")\n  string(APPEND CMAKE_CXX_FLAGS " -Wno-uninitialized")',
            {plain = true}
        )
        io.replace("third_party/protobuf/cmake/install.cmake", "install%(DIRECTORY.-%)", "")
        if package:is_plat("windows") and package:config("vs_runtime"):startswith("MD") then
            io.replace("third_party/fbgemm/CMakeLists.txt", "MT", "MD", {plain = true})
        end

        -- prepare python
        os.vrun("python -m pip install typing_extensions pyyaml")
        local configs = {"-DUSE_MPI=OFF",
                         "-DCMAKE_INSTALL_LIBDIR=lib",
                         "-DBUILD_TEST=OFF",
                         "-DATEN_NO_TEST=ON"}
        if package:config("python") then
            table.insert(configs, "-DBUILD_PYTHON=ON")
            os.vrun("python -m pip install numpy")
        else
            table.insert(configs, "-DBUILD_PYTHON=OFF")
            table.insert(configs, "-DUSE_NUMPY=OFF")
        end

        -- prepare for installation
        local envs = cmake.buildenvs(package, {cmake_generator = "Ninja"})
        if not package:is_plat("macosx") then
            if package:config("blas") == "mkl" then
                table.insert(configs, "-DBLAS=MKL")
                local mkl = package:dep("mkl"):fetch()
                table.insert(configs, "-DINTEL_MKL_DIR=" .. path.directory(mkl.sysincludedirs[1]))
            elseif package:config("blas") == "openblas" then
                table.insert(configs, "-DBLAS=OpenBLAS")
                envs.OpenBLAS_HOME = package:dep("openblas"):installdir()
            elseif package:config("blas") == "eigen" then
                table.insert(configs, "-DBLAS=Eigen")
            end
        end
        if package:config("distributed") then
            envs.libuv_ROOT = package:dep("libuv"):installdir()
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_OPENMP=" .. (package:config("openmp") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_DISTRIBUTED=" .. (package:config("distributed") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_SYSTEM_PYBIND11=" .. (package:config("pybind11") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_CUSTOM_PROTOBUF=" .. (package:config("protobuf-cpp") and "OFF" or "ON"))
        if package:is_plat("windows") then
            table.insert(configs, "-DCAFFE2_USE_MSVC_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end

        local opt = {envs = envs}
        if package:config("ninja") then
            opt.cmake_generator = "Ninja"
        end
        cmake.install(package, configs, opt)

        -- These libs are not installed by cmake but are required for static link.
        local cp_libs = {"libonnx", "libonnx_proto"}
        if package:version():eq("v1.11.0") then
            table.insert(cp_libs, "libbreakpad")
            table.insert(cp_libs, "libbreakpad_common")
        end
        local static_lib_suffix = ".a"
        if package:is_plat("windows") then
            static_lib_suffix = ".lib"
        end
        for _, libname in ipairs(cp_libs) do
            os.trycp(path.join(package:buildir(), "lib", libname .. static_lib_suffix), package:installdir("lib"))
        end

        -- Following patches are needed for static link.
        io.replace(
            path.join(package:installdir("share/cmake/Torch/TorchConfig.cmake")),
            "append_torchlib_if_found(dnnl mkldnn)",
            "append_torchlib_if_found(dnnl_graph dnnl mkldnn)",
            {plain = true}
        )
        if package:version():eq("v1.11.0") then
            io.replace(
                path.join(package:installdir("share/cmake/Torch/TorchConfig.cmake")),
                "append_torchlib_if_found(sleef asmjit)",
                "append_torchlib_if_found(sleef asmjit)\n  append_torchlib_if_found(breakpad breakpad_common)",
                {plain = true}
            )
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto a = torch::ones(3);
                auto b = torch::tensor({1, 2, 3});
                auto c = torch::dot(a, b);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "torch/torch.h"}))
    end)
