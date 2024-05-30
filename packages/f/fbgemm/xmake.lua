package("fbgemm")
    set_homepage("https://github.com/pytorch/FBGEMM")
    set_description("FB (Facebook) + GEMM (General Matrix-Matrix Multiplication) - https://code.fb.com/ml-applications/fbgemm/")
    set_license("BSD")

    add_urls("https://github.com/pytorch/FBGEMM/archive/refs/tags/$(version).tar.gz",
             "https://github.com/pytorch/FBGEMM.git")

    add_versions("v0.7.0", "c51ac26bc0aa8fef7e80631c4abdd3a7c33d1a097359cef9b008bf9e1203c071")

    add_patches("0.7.0", "patches/0.7.0/dep-unbundle.patch", "f3117ff728989146d5ab0c370fe410c73459091f65cae5f6b304e5637889fb8f")

    -- need libtorch
    add_configs("gpu", {description = "Build fbgemm_gpu library", default = false, type = "boolean"})
    add_configs("cpu", {description = "Build FBGEMM_GPU without GPU support", default = false, type = "boolean"})
    add_configs("rocm", {description = "Build FBGEMM_GPU for ROCm", default = false, type = "boolean"})

    add_deps("cmake", "python", {kind = "binary"})
    add_deps("asmjit", "cpuinfo", "openmp")

    -- mingw support: https://github.com/pytorch/FBGEMM/pull/2114
    -- arm support: https://github.com/pytorch/FBGEMM/issues/2074
    on_install("windows|x64", "linux|x86_64", "macosx|x86_64", function (package)
        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})

        if not package:config("shared") then
            package:add("defines", "FBGEMM_STATIC")
        end

        local configs = {"-DFBGEMM_BUILD_TESTS=OFF", "-DFBGEMM_BUILD_BENCHMARKS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DFBGEMM_LIBRARY_TYPE=" .. (package:config("shared") and "shared" or "static"))

        table.insert(configs, "-DFBGEMM_BUILD_FBGEMM_GPU=" .. (package:config("gpu") and "ON" or "OFF"))
        table.insert(configs, "-DFBGEMM_CPU_ONLY=" .. (package:config("cpu") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_ROCM=" .. (package:config("rocm") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = {"asmjit", "cpuinfo"}})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                fbgemm::Xor128();
            }
        ]]}, {configs = {languages = "c++20"}, includes = "fbgemm/QuantUtilsAvx2.h"}))
    end)
