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

    add_patches("1.9.x", path.join(os.scriptdir(), "patches", "1.9.0", "gcc11.patch"), "4191bb3296f18f040c230d7c5364fb160871962d6278e4ae0f8bc481f27d8e4b")

    add_configs("python", {description = "Build python interface.", default = false, type = "boolean"})
    add_configs("ninja", {description = "Use ninja as build tool.", default = true, type = "boolean"})
    if not is_plat("macosx") then
        add_configs("blas", {description = "Set BLAS vendor.", default = "openblas", type = "string", values = {"mkl", "openblas"}})
    end

    add_deps("cmake")
    add_deps("python 3.x", {kind = "binary", system = false})
    add_deps("libuv")
    add_deps("cuda", {optional = true, configs = {utils = {"nvrtc", "cudnn", "cufft", "curand", "cublas", "cudart_static"}}})
    add_deps("nvtx", {optional = true, system = true})
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
        if not package:is_plat("macosx") and package:config("blas") then
            package:add("deps", package:config("blas"))
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
        local has_cuda = package:dep("cuda"):exists() and package:dep("nvtx"):exists()
        local libnames = {"torch", "torch_cpu"}
        if has_cuda then
            table.insert(libnames, "torch_cuda")
        end
        table.insert(libnames, "c10")
        if has_cuda then
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
            for _, lib in ipairs({"nnpack", "pytorch_qnnpack", "qnnpack", "XNNPACK", "caffe2_protos", "protobuf-lite", "protobuf", "protoc", "onnx", "onnx_proto", "foxi_loader", "pthreadpool", "eigen_blas", "fbgemm", "cpuinfo", "clog", "dnnl", "mkldnn", "sleef", "asmjit", "fmt"}) do
                package:add("links", lib)
            end
        end
        package:add("links", "kineto")

        -- some patches to the third-party cmake files
        io.replace("third_party/fbgemm/CMakeLists.txt", "PRIVATE FBGEMM_STATIC", "PUBLIC FBGEMM_STATIC", {plain = true})
        io.replace("third_party/protobuf/cmake/install.cmake", "install%(DIRECTORY.-%)", "")
        if package:is_plat("windows") and package:config("vs_runtime"):startswith("MD") then
            io.replace("third_party/fbgemm/CMakeLists.txt", "MT", "MD", {plain = true})
        end

        -- prepare python
        os.vrun("python -m pip install typing_extensions pyyaml")
        local configs = {"-DUSE_MPI=OFF", "-DCMAKE_INSTALL_LIBDIR=lib"}
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
            end
        end
        envs.libuv_ROOT = package:dep("libuv"):installdir()
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DCAFFE2_USE_MSVC_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end

        local opt = {envs = envs}
        if package:config("ninja") then
            opt.cmake_generator = "Ninja"
        end
        cmake.install(package, configs, opt)
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
