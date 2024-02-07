package("openblas")
    set_homepage("http://www.openblas.net/")
    set_description("OpenBLAS is an optimized BLAS library based on GotoBLAS2 1.13 BSD version.")
    set_license("BSD-3-Clause")

    if is_plat("windows") then
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
        end
    else
        add_urls("https://github.com/OpenMathLib/OpenBLAS/releases/download/v$(version)/OpenBLAS-$(version).tar.gz")
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
    end

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = is_plat("windows")})
    add_configs("lapack", {description = "Build LAPACK", default = not is_plat("android"), type = "boolean", readonly = (is_plat("windows") or is_plat("android"))})
    add_configs("dynamic_arch", {description = "Enable dynamic arch dispatch", default = (is_plat("linux") or is_plat("windows")), type = "boolean", readonly = not is_plat("linux")})
    add_configs("openmp", {description = "Compile with OpenMP enabled.", default = (is_plat("windows") or is_plat("linux")), type = "boolean", readonly = not is_plat("linux")})
    add_configs("fortran", {description = "Compile with Fortran enabled.", default = false, type = "boolean", readonly = (is_plat("windows") or is_plat("android"))})
    
    if not is_plat("windows") then
        add_deps("cmake")
    end
    if is_plat("linux") then
        add_extsources("apt::libopenblas-dev", "pacman::libopenblas")
        add_syslinks("pthread")
    end
  
    on_load("linux", "macosx", "mingw", function (package)
        if package:config("openmp") then package:add("deps", "openmp") end
        if package:config("fortran") then package:add("deps", "gfortran", {system = true}) end
    end)

    on_load("windows|x64", "windows|x86", function (package)
        package:add("defines", "HAVE_LAPACK_CONFIG_H")
    end)

    on_install("windows|x64", "windows|x86", function (package)
        os.cp("bin", package:installdir())
        os.cp("include", package:installdir())
        os.cp(path.join("lib", "libopenblas.lib"), path.join(package:installdir("lib"), "openblas.lib"))
        package:addenv("PATH", "bin")
    end)

    on_install("macosx", "linux", "android", "mingw", function (package)
        local configs = {"-DCMAKE_BUILD_TYPE=Release", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DDYNAMIC_ARCH=" .. (package:config("dynamic_arch") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_OPENMP=" .. (package:config("openmp") and "ON" or "OFF"))
        table.insert(configs, "-DNOFORTRAN=" .. (package:config("fortran") and "OFF" or "ON"))
        if package:is_plat("mingw") then
            table.insert(configs, "-DTARGET=GENERIC")
            if package:is_arch("i386", "x86") then table.insert(configs, "-DBINARY=32") end
        end
        if package:is_plat("macosx") and package:is_arch("arm64") then
            table.insert(configs, "-DTARGET=VORTEX") 
            table.insert(configs, "-DBINARY=64")
        end
        if package:config("lapack") then
            if not package:config("fortran") then table.insert(configs, "-DC_LAPACK=ON") end
            table.insert(configs, "-DBUILD_LAPACK_DEPRECATED=OFF")
        else
            table.insert(configs, "-DONLY_CBLAS=ON")
            table.insert(configs, "-DBUILD_WITHOUT_LAPACK=ON")
        end
        import("package.tools.cmake").install(package, configs)

        os.mv(package:installdir() .. "/include/openblas/*" , package:installdir("include"))
        os.rm(package:installdir("include/openblas"))
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                double A[6] = {1.0,2.0,1.0,-3.0,4.0,-1.0};
                double B[6] = {1.0,2.0,1.0,-3.0,4.0,-1.0};
                double C[9] = {0.8,0.2,0.5,-0.3,0.5,0.2,0.1,0.4,0.1};

                cblas_dgemm(CblasColMajor,CblasNoTrans,CblasTrans,3,3,2,1,A,3,B,3,2,C,3);
            }
        ]]}, {includes = {"cblas.h"}}))

        if package:config("lapack") then
            assert(package:check_csnippets({test = [[
                void test() {
                    double A[9] = {0.8,0.2,0.5,-0.3,0.5,0.2,0.1,0.4,0.1};
                    double x[3] = {1.0,2.0,3.0};
                    lapack_int ipiv[3];

                    LAPACKE_dgesv(LAPACK_COL_MAJOR, 3, 1, A, 3, ipiv, x, 3);
                }
            ]]}, {includes = {"lapacke.h"}}))
        end
    end)
