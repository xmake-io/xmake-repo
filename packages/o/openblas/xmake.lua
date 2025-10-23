package("openblas")
    set_homepage("http://www.openblas.net/")
    set_description("OpenBLAS is an optimized BLAS library based on GotoBLAS2 1.13 BSD version.")
    set_license("BSD-3-Clause")

    if is_plat("windows") and not is_arch("arm64") then
        if is_arch("x64", "x86_64") then
            add_urls("https://github.com/OpenMathLib/OpenBLAS/releases/download/v$(version)/OpenBLAS-$(version)-x64.zip")
            add_versions("0.3.12", "f1d231594365d5c7f2c625f9d8bd4eeea4f7b748675a95301d3cb2c0aa118e26")
            add_versions("0.3.13", "85cacd71dec9bc1e1168a8463fd0aa29a31f449b4583ed3a1c689a56df8eae29")
            add_versions("0.3.15", "afc029572a84820596fe81f1faeb909ada5bab27d091285fdd80bc2a8231f4a6")
            add_versions("0.3.17", "85b650e6519371b80c1fc10cbaa74af671df9215a53c5d11c64e758396f030ef")
            add_versions("0.3.18", "767757039c354b6625c497a856c362546c1b1e7400278ffb40e3b9bf731f3b27")
            add_versions("0.3.19", "d85b09d80bbb40442d608fa60353ccec5f112cebeccd805c0e139057e26d1795")
            add_versions("0.3.20", "cacfb8563e2a98260e35a09c92fd3b7383a9cd1367444edfa1b46cb0225ee9c3")
            add_versions("0.3.21", "ecf1853ce92696fb8531c941c50e983ea8fa673c118a87298a075c045d52a3ca")
            add_versions("0.3.23", "e3a82e60db8d6197228790567e7cf74f2c421a65b29f848977a07b5457debdaa")
            add_versions("0.3.24", "6335128ee7117ea2dd2f5f96f76dafc17256c85992637189a2d5f6da0c608163")
            add_versions("0.3.26", "859c510a962a30ef1b01aa93cde26fdb5fb1050f94ad5ab2802eba3731935e06")
            add_versions("0.3.27", "7b4d7504f274f8e26001aab4e25ec05032d90b8785b0355dc0d09247858d9f1e")
            add_versions("0.3.28", "4cbd0e5daa3fb083b18f5e5fa6eefe79e2f2c51a6d539f98a3c6309a21160042")
            add_versions("0.3.30", "8b04387766efc05c627e26d24797ec0d4ed4c105ec14fa7400aa84a02db22b66")
        elseif is_arch("x86") then
            add_urls("https://github.com/OpenMathLib/OpenBLAS/releases/download/v$(version)/OpenBLAS-$(version)-x86.zip")
            add_versions("0.3.15", "bcde933737b477813eaac290de5cb8756d3b42199e8ef5f44b23ae5f06fe0834")
            add_versions("0.3.17", "8258a9a22075280fb02b65447ea77d9439a0097711e220fc4ae8f92927f32273")
            add_versions("0.3.18", "c24ecd6e5f561de3861bf714b35e0957a27ee0e03ab4d2867d08377892daf66e")
            add_versions("0.3.19", "478cbaeb9364b4681a7c982626e637a5a936514a45e12b6f0caddbcb9483b795")
            add_versions("0.3.20", "0ee249246af7ce2fd66f86cb9350f5f5a7b97496b9b997bfd0680048dd194158")
            add_versions("0.3.21", "936416a0fec5506af9cf040c9de5c7edbd0ff18b53431799d1a43e47f9eba64e")
            add_versions("0.3.24", "92f8e0c73e1eec3c428b210fbd69b91e966f8cf1f998f3b60a52f024b2bf9d27")
            add_versions("0.3.26", "9c3d48c3c21cd2341d642a63ee8a655205587befdab46462df7e0104d6771f67")
            add_versions("0.3.27", "0cb61cff9eac7fcc07036880dfeec7a2e194d0412524901bf03e55208f51f900")
            add_versions("0.3.28", "4a14ba2b43937278616cd0883e033cc07ee1331afdd2d264ad81432bd7b16c7b")
            add_versions("0.3.30", "5eb9df2ccaacf686028f1d08444b9116c0e55c5264f462dafd0b036a2979737a")
        end

        add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    else
        add_urls("https://github.com/OpenMathLib/OpenBLAS/releases/download/v$(version)/OpenBLAS-$(version).tar.gz",
                 "https://github.com/OpenMathLib/OpenBLAS.git")
        add_versions("0.3.12", "65a7d3a4010a4e3bd5c0baa41a234797cd3a1735449a4a5902129152601dc57b")
        add_versions("0.3.13", "79197543b17cc314b7e43f7a33148c308b0807cd6381ee77f77e15acf3e6459e")
        add_versions("0.3.15", "30a99dec977594b387a17f49904523e6bc8dd88bd247266e83485803759e4bbe")
        add_versions("0.3.17", "df2934fa33d04fd84d839ca698280df55c690c86a5a1133b3f7266fce1de279f")
        add_versions("0.3.18", "1632c1e8cca62d8bed064b37747e331a1796fc46f688626337362bf0d16aeadb")
        add_versions("0.3.19", "947f51bfe50c2a0749304fbe373e00e7637600b0a47b78a51382aeb30ca08562")
        add_versions("0.3.20", "8495c9affc536253648e942908e88e097f2ec7753ede55aca52e5dead3029e3c")
        add_versions("0.3.21", "f36ba3d7a60e7c8bcc54cd9aaa9b1223dd42eaf02c811791c37e8ca707c241ca")
        add_versions("0.3.23", "5d9491d07168a5d00116cdc068a40022c3455bf9293c7cb86a65b1054d7e5114")
        add_versions("0.3.24", "ceadc5065da97bd92404cac7254da66cc6eb192679cf1002098688978d4d5132")
        add_versions("0.3.26", "4e6e4f5cb14c209262e33e6816d70221a2fe49eb69eaf0a06f065598ac602c68")
        add_versions("0.3.27", "aa2d68b1564fe2b13bc292672608e9cdeeeb6dc34995512e65c3b10f4599e897")
        add_versions("0.3.28", "f1003466ad074e9b0c8d421a204121100b0751c96fc6fcf3d1456bd12f8a00a1")
        add_versions("0.3.30", "27342cff518646afb4c2b976d809102e368957974c250a25ccc965e53063c95d")

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
    end

    if is_plat("linux") then
        add_extsources("apt::libopenblas-dev", "pacman::openblas")
        add_syslinks("pthread")
    elseif is_plat("macosx") then
        add_extsources("brew::openblas64", "brew::openblas")
        add_frameworks("Accelerate")
    end

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
        if package:version():ge("0.3.30") or not package:is_plat("macosx", "linux", "mingw@windows,msys") then
            package:add("deps", "cmake")
            package:add("includedirs", "include", "include/openblas")
        end
        if package:config("fortran") then
            package:add("deps", "gfortran")
        end
        if package:config("openmp") then
            package:add("deps", "openmp")
        end
    end)


    on_install("windows|x64", "windows|x86", function (package)
        os.cp(path.join("bin", "libopenblas.dll"), package:installdir("bin"))
        os.cp("include", package:installdir())
        if package:version():eq("0.3.28") then
            os.cp("libopenblas.lib", path.join(package:installdir("lib"), "openblas.lib"))
        else
            os.cp(path.join("lib", "libopenblas.lib"), path.join(package:installdir("lib"), "openblas.lib"))
        end
        package:addenv("PATH", "bin")
    end)

    on_install("!windows or (windows|!x64 and windows|!x86)", function (package)
        if package:version():lt("0.3.30") and package:is_plat("macosx", "linux", "mingw@windows,msys") then
            import("lib.detect.find_tool")
            import("package.tools.make")
            local configs = {}
            if package:is_plat("linux") then
                table.insert(configs, "CC=" .. package:build_getenv("cc"))
            end
            if package:is_plat("macosx") and package:is_arch("arm64") then
                table.insert(configs, "TARGET=VORTEX")
                table.insert(configs, "BINARY=64")
                table.insert(configs, "CFLAGS=-arch arm64")
                table.insert(configs, "LDFLAGS=-arch arm64")
            end
            if package:debug() then table.insert(configs, "DEBUG=1") end
            if package:config("openmp") then table.insert(configs, "USE_OPENMP=1") end
            if not package:config("shared") then
                table.insert(configs, "NO_SHARED=1")
            else
                table.insert(configs, "NO_STATIC=1")
            end
            if package:config("fortran") then
                local fortran = find_tool("gfortran")
                if fortran then
                    table.insert(configs, "FC=" .. fortran.program)
                end
            else
                table.insert(configs, "NO_FORTRAN=1")
            end
            if package:is_plat("mingw") then
                if package:is_arch("i386", "x86") then
                    table.insert(configs, "BINARY=32")
                end
            else
                local cflags
                local ldflags
                if package:config("openmp") then
                    local openmp = package:dep("openmp"):fetch()
                    if openmp then
                        cflags = openmp.cflags
                        local libomp = package:dep("libomp")
                        if libomp then
                            local fetchinfo = libomp:fetch()
                            if fetchinfo then
                                local includedirs = fetchinfo.sysincludedirs or fetchinfo.includedirs
                                for _, includedir in ipairs(includedirs) do
                                    cflags = (cflags or "") .. " -I" .. includedir
                                end
                                for _, linkdir in ipairs(fetchinfo.linkdirs) do
                                    ldflags = (ldflags or "") .. " -Wl,-L" .. linkdir
                                end
                                for _, link in ipairs(fetchinfo.links) do
                                    ldflags = (ldflags or "") .. " -Wl,-l" .. link
                                end
                            end
                        end
                    end
                end
                if package:config("fortran") then
                    local gfortran = package:dep("gfortran"):fetch()
                    if gfortran then
                        for _, linkdir in ipairs(gfortran.linkdirs) do
                            ldflags = (ldflags or "") .. " -Wl,-L" .. linkdir
                        end
                    end
                end
                if cflags then
                    io.replace("Makefile.system", "-fopenmp", cflags, {plain = true})
                end
                if ldflags then
                    table.insert(configs, "LDFLAGS=" .. ldflags)
                end
            end
            make.build(package, configs)
            make.make(package, table.join("install", "PREFIX=" .. package:installdir():gsub("\\", "/"), configs))
        else
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
        end
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
