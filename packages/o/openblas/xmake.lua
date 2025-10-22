package("openblas")
    set_homepage("http://www.openblas.net/")
    set_description("OpenBLAS is an optimized BLAS library based on GotoBLAS2 1.13 BSD version.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/OpenMathLib/OpenBLAS/archive/refs/tags/$(version).tar.gz",
             "https://github.com/OpenMathLib/OpenBLAS.git")
    add_versions("v0.3.12", "65a7d3a4010a4e3bd5c0baa41a234797cd3a1735449a4a5902129152601dc57b")
    add_versions("v0.3.13", "79197543b17cc314b7e43f7a33148c308b0807cd6381ee77f77e15acf3e6459e")
    add_versions("v0.3.15", "30a99dec977594b387a17f49904523e6bc8dd88bd247266e83485803759e4bbe")
    add_versions("v0.3.17", "df2934fa33d04fd84d839ca698280df55c690c86a5a1133b3f7266fce1de279f")
    add_versions("v0.3.18", "1632c1e8cca62d8bed064b37747e331a1796fc46f688626337362bf0d16aeadb")
    add_versions("v0.3.19", "947f51bfe50c2a0749304fbe373e00e7637600b0a47b78a51382aeb30ca08562")
    add_versions("v0.3.20", "8495c9affc536253648e942908e88e097f2ec7753ede55aca52e5dead3029e3c")
    add_versions("v0.3.21", "f36ba3d7a60e7c8bcc54cd9aaa9b1223dd42eaf02c811791c37e8ca707c241ca")
    add_versions("v0.3.23", "5d9491d07168a5d00116cdc068a40022c3455bf9293c7cb86a65b1054d7e5114")
    add_versions("v0.3.24", "ceadc5065da97bd92404cac7254da66cc6eb192679cf1002098688978d4d5132")
    add_versions("v0.3.26", "4e6e4f5cb14c209262e33e6816d70221a2fe49eb69eaf0a06f065598ac602c68")
    add_versions("v0.3.27", "aa2d68b1564fe2b13bc292672608e9cdeeeb6dc34995512e65c3b10f4599e897")
    add_versions("v0.3.28", "f1003466ad074e9b0c8d421a204121100b0751c96fc6fcf3d1456bd12f8a00a1")
    add_versions("v0.3.30", "27342cff518646afb4c2b976d809102e368957974c250a25ccc965e53063c95d")

    add_configs("lapack",            {description = "Build LAPACK.",                                                                                                                    default = true,   type = "boolean"})
    add_configs("lapacke",           {description = "Build the C interface to LAPACK.",                                                                                                 default = true,   type = "boolean"})
    add_configs("lapack_deprecated", {description = "When building LAPACK, include also some older, deprecated routines.",                                                              default = true,   type = "boolean"})
    add_configs("c_lapack",          {description = "Build LAPACK from C sources instead of the original Fortran.",                                                                     default = false,  type = "boolean"})
    add_configs("cblas",             {description = "Build the C interface (CBLAS) to the BLAS functions.",                                                                             default = true,   type = "boolean"})
    add_configs("dynamic_arch",      {description = "Include support for multiple CPU targets, with automatic selection at runtime (x86/x86_64, aarch64, ppc or RISCV64-RVV1.0 only).", default = false,  type = "boolean"})
    add_configs("dynamic_older",     {description = "Include specific support for older x86 cpu models (Penryn,Dunnington,Atom,Nano,Opteron) with DYNAMIC_ARCH.",                       default = false,  type = "boolean"})
    add_configs("relapack",          {description = "Build with ReLAPACK (recursive implementation of several LAPACK functions on top of standard LAPACK).",                            default = false,  type = "boolean"})
    add_configs("locking",           {description = "Use locks even in single-threaded builds to make them callable from multiple threads.",                                            default = false,  type = "boolean"})
    add_configs("thread",            {description = "Enable threads support.",                                                                                                          default = false,  type = "boolean"})
    add_configs("openmp",            {description = "Compile with OpenMP enabled.",                                                                                                     default = false,  type = "boolean"})
    add_configs("fortran",           {description = "Compile with fortran enabled.",                                                                                                    default = false,  type = "boolean"})
    add_configs("target",            {description = "Specify CPU architecture (see TargetList.txt).",                                                                                   default = "auto", type = "string"})

    if is_plat("linux") then
        add_extsources("apt::libopenblas-dev", "pacman::openblas")
        add_syslinks("pthread")
    elseif is_plat("macosx") then
        add_extsources("brew::openblas64", "brew::openblas")
        add_frameworks("Accelerate")
    end

    add_deps("cmake")
    add_includedirs("include", "include/openblas")

    if on_check then
        on_check("cross", "mingw@macosx", "iphoneos", "wasm", function (package)
            assert(package:config("target") ~= "auto", "When cross compiling, a target is required, e.g., add_requires(\"openblas\", {configs = {target = \"your_target\"}}).")
        end)
        on_check("windows|arm64", function (package)
            assert(not package:is_cross(), "package(openblas) does not support cross-compiling for Windows ARM64 yet.")
        end)
        on_check("android", function (package)
            local ndk_sdkver = package:toolchain("ndk"):config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) > 21, "package(openblas) does not support ndk api <= 21 yet.")
        end)
    end

    on_load(function (package)
        if package:config("fortran") then
            package:add("deps", "gfortran")
        end
        if package:config("openmp") then
            package:add("deps", "openmp")
        end
    end)

    on_install(function (package)
        if package:has_tool("cxx", "cl") then
            io.replace("CMakeLists.txt", "/Zi", "/Z7", {plain = true})
        end
        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DBUILD_BENCHMARKS=OFF",
            "-DCMAKE_POLICY_DEFAULT_CMP0077=NEW",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_WITHOUT_LAPACK="  .. (package:config("lapack") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_WITHOUT_LAPACKE=" .. (package:config("lapacke") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_LAPACK_DEPRECATED=" .. (package:config("lapack_deprecated") and "ON" or "OFF"))
        table.insert(configs, "-DC_LAPACK=" .. (package:config("c_lapack") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_WITHOUT_CBLAS=" .. (package:config("cblas") and "OFF" or "ON"))
        table.insert(configs, "-DDYNAMIC_ARCH=" .. (package:config("dynamic_arch") and "ON" or "OFF"))
        table.insert(configs, "-DDYNAMIC_OLDER=" .. (package:config("dynamic_older") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_RELAPACK=" .. (package:config("relapack") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_LOCKING=" .. (package:config("locking") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_THREAD=" .. (package:config("thread") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_OPENMP=" .. (package:config("openmp") and "ON" or "OFF"))
        table.insert(configs, "-DNOFORTRAN=" .. (package:config("fortran") and "OFF" or "ON"))
        if package:config("target") ~= "auto" then
            table.insert(configs, "-DTARGET=" .. package:config("target"))
        end
        if package:is_plat("windows") and package:has_runtime("MT", "MTd") then
            table.insert(configs, "-DMSVC_STATIC_CRT=ON")
        end

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                double A[6] = {1.0, 2.0, 1.0, -3.0, 4.0, -1.0};
                double B[6] = {1.0, 2.0, 1.0, -3.0, 4.0, -1.0};
                double C[9] = {.5, .5, .5, .5, .5, .5, .5, .5, .5};
                cblas_dgemm(CblasColMajor, CblasNoTrans, CblasTrans, 3, 3, 2, 1, A, 3, B, 3, 2, C, 3);
            }
        ]]}, {includes = "cblas.h"}))
    end)
