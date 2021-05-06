package("libtorch")

    set_homepage("https://pytorch.org/")
    set_description("An open source machine learning framework that accelerates the path from research prototyping to production deployment.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/pytorch/pytorch.git")
    add_versions("v1.8.0", "37c1f4a7fef115d719104e871d0cf39434aa9d56")
    add_versions("v1.8.1", "56b43f4fec1f76953f15a627694d4bba34588969")

    add_configs("python", {description = "Build python interface.", default = false, type = "boolean"})
    add_configs("ninja", {description = "Use ninja as build tool.", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("python 3.x", {kind = "binary", system = false})
    add_deps("libuv")
    add_deps("cuda", {optional = true, configs = {utils = {"nvrtc", "cudnn", "cufft", "curand", "cublas", "cudart_static"}}})
    add_deps("nvtx", "mkl", {optional = true, system = true})
    add_includedirs("include")
    add_includedirs("include/torch/csrc/api/include")

    -- enable long paths for git submodule on windows
    if is_host("windows") and set_policy then
        set_policy("platform.longpaths", true)
    end

    -- prevent the link to the libraries found automatically
    add_links("")

    on_load("windows|x64", "macosx", "linux", function (package)
        if package:config("ninja") then
            package:add("deps", "ninja")
        end

        if not package:is_plat("macosx") then
            if not find_package("mkl") then
                package:add("deps", "openblas")
            end
        end
    end)

    on_install("windows|x64", "macosx", "linux", function (package)
        import("package.tools.cmake")

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

        -- some patches to the third-party cmake files
        io.replace("cmake/Modules/FindMKL.cmake", "MSVC AND NOT CMAKE_CXX_COMPILER_ID STREQUAL \"Intel\"", "FALSE", {plain = true})
        io.replace("third_party/fbgemm/CMakeLists.txt", "PRIVATE FBGEMM_STATIC", "PUBLIC FBGEMM_STATIC", {plain = true})
        io.replace("third_party/protobuf/cmake/install.cmake", "install%(DIRECTORY.-%)", "")
        io.replace("third_party/ideep/mkl-dnn/src/CMakeLists.txt", "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}", "${CMAKE_INSTALL_LIBDIR}", {plain = true})
        if package:is_plat("windows") and package:config("vs_runtime"):startswith("MD") then
            io.replace("third_party/fbgemm/CMakeLists.txt", "MT", "MD", {plain = true})
        end

        -- prepare python
        os.vrun("python -m pip install typing_extensions pyyaml")
        local configs = {"-DUSE_MPI=OFF"}
        if package:config("python") then
            table.insert(configs, "-DBUILD_PYTHON=ON")
            os.vrun("python -m pip install numpy")
        else
            table.insert(configs, "-DBUILD_PYTHON=OFF")
        end

        -- prepare for installation
        local opt = {}
        if package:config("ninja") then
            opt.cmake_generator = "Ninja"
        end
        local envs = cmake.buildenvs(package, opt)
        if not package:is_plat("macosx") then
            if package:dep("mkl"):exists() then
                table.insert(configs, "-DBLAS=MKL")
                local mkl = package:dep("mkl"):fetch()
                table.insert(configs, "-DINTEL_MKL_DIR=" .. path.directory(mkl.sysincludedirs[1]))
            else
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
        opt.envs = envs
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
