package("openblas")

    set_homepage("http://www.openblas.net/")
    set_description("OpenBLAS is an optimized BLAS library based on GotoBLAS2 1.13 BSD version.")

    if is_plat("windows") then
        if is_arch("x64", "x86_64") then
            add_urls("https://github.com/xianyi/OpenBLAS/releases/download/v$(version)/OpenBLAS-$(version)-x64.zip")
            add_versions("0.3.12", "f1d231594365d5c7f2c625f9d8bd4eeea4f7b748675a95301d3cb2c0aa118e26")
            add_versions("0.3.13", "85cacd71dec9bc1e1168a8463fd0aa29a31f449b4583ed3a1c689a56df8eae29")
            add_versions("0.3.15", "afc029572a84820596fe81f1faeb909ada5bab27d091285fdd80bc2a8231f4a6")
            add_versions("0.3.17", "85b650e6519371b80c1fc10cbaa74af671df9215a53c5d11c64e758396f030ef")
            add_versions("0.3.18", "767757039c354b6625c497a856c362546c1b1e7400278ffb40e3b9bf731f3b27")
        elseif is_arch("x86") then
            add_urls("https://github.com/xianyi/OpenBLAS/releases/download/v$(version)/OpenBLAS-$(version)-x86.zip")
            add_versions("0.3.15", "bcde933737b477813eaac290de5cb8756d3b42199e8ef5f44b23ae5f06fe0834")
            add_versions("0.3.17", "8258a9a22075280fb02b65447ea77d9439a0097711e220fc4ae8f92927f32273")
            add_versions("0.3.18", "c24ecd6e5f561de3861bf714b35e0957a27ee0e03ab4d2867d08377892daf66e")
        end

        add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    else
        add_urls("https://github.com/xianyi/OpenBLAS/releases/download/v$(version)/OpenBLAS-$(version).tar.gz")
        add_versions("0.3.12", "65a7d3a4010a4e3bd5c0baa41a234797cd3a1735449a4a5902129152601dc57b")
        add_versions("0.3.13", "79197543b17cc314b7e43f7a33148c308b0807cd6381ee77f77e15acf3e6459e")
        add_versions("0.3.15", "30a99dec977594b387a17f49904523e6bc8dd88bd247266e83485803759e4bbe")
        add_versions("0.3.17", "df2934fa33d04fd84d839ca698280df55c690c86a5a1133b3f7266fce1de279f")
        add_versions("0.3.18", "1632c1e8cca62d8bed064b37747e331a1796fc46f688626337362bf0d16aeadb")

        add_configs("with_fortran", {description="Compile with fortran enabled.", default = is_plat("linux"), type = "boolean"})
    end

    if is_plat("linux") then
        add_extsources("apt::libopenblas-dev")
        add_syslinks("pthread")
    elseif is_plat("macosx") then
        add_frameworks("Accelerate")
    end
    on_load("macosx", "linux", function (package)
        if package:config("with_fortran") then
            package:add("syslinks", "gfortran")
        end
    end)

    on_install("windows", function (package)
        os.mv(path.join("bin", "libopenblas.dll"), package:installdir("bin"))
        os.mv("include", package:installdir())
        os.mv(path.join("lib", "libopenblas.lib"), path.join(package:installdir("lib"), "openblas.lib"))
        package:addenv("PATH", "bin")
    end)

    on_install("macosx", "linux", "mingw@windows,msys", function (package)
        local configs = {}
        if package:config("debug") then table.insert(configs, "DEBUG=1") end
        if not package:config("shared") then
            table.insert(configs, "NO_SHARED=1")
        else
            table.insert(configs, "NO_STATIC=1")
        end
        if package:config("with_fortran") then
            import("lib.detect.find_tool")
            local fortran = find_tool("gfortran")
            if fortran then
                table.insert(configs, "FC=" .. fortran.program)
            else
                raise("gfortran not found!")
            end
        else
            table.insert(configs, "NO_FORTRAN=1")
        end
        if package:is_plat("mingw") then
            if package:is_arch("i386", "x86") then
                table.insert(configs, "BINARY=32")
            end
            os.vrunv("mingw32-make", configs)
            os.vrunv("mingw32-make install PREFIX=" .. package:installdir(), configs)
            if package:config("shared") then
                package:addenv("PATH", "bin")
            end
        else
            os.vrunv("make", configs)
            os.vrunv("make install PREFIX=" .. package:installdir(), configs)
        end
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                double A[6] = {1.0,2.0,1.0,-3.0,4.0,-1.0};
                double B[6] = {1.0,2.0,1.0,-3.0,4.0,-1.0};
                double C[9] = {.5,.5,.5,.5,.5,.5,.5,.5,.5};
                cblas_dgemm(CblasColMajor,CblasNoTrans,CblasTrans,3,3,2,1,A,3,B,3,2,C,3);
            }
        ]]}, {includes = "cblas.h"}))
    end)
