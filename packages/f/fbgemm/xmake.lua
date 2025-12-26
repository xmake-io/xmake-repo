package("fbgemm")
    set_homepage("https://github.com/pytorch/FBGEMM")
    set_description("FB (Facebook) + GEMM (General Matrix-Matrix Multiplication) - https://code.fb.com/ml-applications/fbgemm/")
    set_license("BSD")

    add_urls("https://github.com/pytorch/FBGEMM/archive/refs/tags/$(version).tar.gz",
             "https://github.com/pytorch/FBGEMM.git", {submodules = false})

    add_versions("v1.4.2", "525abde5f161c1730952f175adfcbc77a4b7eeebd7b7a342170e9011734164cf")
    add_versions("v1.2.0", "f679c3a9d0b0b1511122dca39c553b52d1fbf23c563f897d8218746a087f8bed")
    add_versions("v1.1.2", "15f89d724a00ce2f82ea7c1782e3fdc5c472d0ad37698498c0f419cc4924d8c8")
    add_versions("v1.1.0", "ca55019d6b75952a14c64aed0b6b90df06b21196a1152ab97c385964cc996a30")
    add_versions("v0.8.0", "f754dbc6becf8ece0474872c4e797445b55c21799c1f1d219470c0c5818207dd")
    add_versions("v0.7.0", "c51ac26bc0aa8fef7e80631c4abdd3a7c33d1a097359cef9b008bf9e1203c071")

    add_patches(">=1.1.0", "patches/1.1.0/dep-unbundle.patch", "c1c4f6cc5d319d827959c70396a2dade6a0c7aa4db9c42f2b29ac76634949b6f")
    add_patches("0.8.0", "patches/0.8.0/dep-unbundle.patch", "505ccda3b12ec519cb0732352b223862b3470c207e03e84889b977cbdc1d9aae")
    add_patches("0.7.0", "patches/0.7.0/dep-unbundle.patch", "f3117ff728989146d5ab0c370fe410c73459091f65cae5f6b304e5637889fb8f")

    if is_plat("windows") then
        add_patches("0.8.0", "patches/0.8.0/msvc-omp.patch", "d4a7830e40a476ffdeda00d2f7901a7db6e7950392ff672144d5e9f3c37ced2f")
    end

    -- need libtorch
    add_configs("gpu", {description = "Build fbgemm_gpu library", default = false, type = "boolean"})
    add_configs("cpu", {description = "Build FBGEMM_GPU without GPU support", default = false, type = "boolean"})
    add_configs("rocm", {description = "Build FBGEMM_GPU for ROCm", default = false, type = "boolean"})

    add_deps("cmake", "python", {kind = "binary"})
    add_deps("asmjit", "cpuinfo", "openmp")

    -- mingw support: https://github.com/pytorch/FBGEMM/pull/2114
    -- arm support: https://github.com/pytorch/FBGEMM/issues/2074
    on_install("windows|x64", "linux|x86_64", "macosx|x86_64", function (package)
        if not package:config("shared") then
            package:add("defines", "FBGEMM_STATIC")
        end

        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})

        local configs = {"-DFBGEMM_BUILD_TESTS=OFF", "-DFBGEMM_BUILD_BENCHMARKS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DFBGEMM_LIBRARY_TYPE=" .. (package:config("shared") and "shared" or "static"))
        if package:config("asan") then
            table.insert(configs, "-DUSE_SANITIZER=address")
        end

        table.insert(configs, "-DFBGEMM_BUILD_FBGEMM_GPU=" .. (package:config("gpu") and "ON" or "OFF"))
        table.insert(configs, "-DFBGEMM_CPU_ONLY=" .. (package:config("cpu") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_ROCM=" .. (package:config("rocm") and "ON" or "OFF"))

        local opt = {packagedeps = {"asmjit", "cpuinfo"}}
        if package:has_tool("cxx", "cl") then
            opt.cxflags = "/bigobj"
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                fbgemm::Xor128();
            }
        ]]}, {configs = {languages = "c++20"}, includes = "fbgemm/QuantUtilsAvx2.h"}))
    end)
