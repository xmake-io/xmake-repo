package("openblas")

    set_homepage("http://www.openblas.net/")
    set_description("OpenBLAS is an optimized BLAS library based on GotoBLAS2 1.13 BSD version.")

    if is_plat("windows") then
        if is_arch("x64", "x86_64") then
            add_urls("https://github.com/xianyi/OpenBLAS/releases/download/v$(version)/OpenBLAS-$(version)-x64.zip")
            add_versions("0.3.12", "f1d231594365d5c7f2c625f9d8bd4eeea4f7b748675a95301d3cb2c0aa118e26")
        end
    else
        add_urls("https://github.com/xianyi/OpenBLAS/releases/download/v$(version)/OpenBLAS-$(version).tar.gz")
        add_versions("0.3.12", "65a7d3a4010a4e3bd5c0baa41a234797cd3a1735449a4a5902129152601dc57b")

        add_configs("with_fortran", {description="Compile with fortran enabled.", default = true, type = "boolean"})
    end

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install("windows", function (package)
        if package:is_arch("x64", "x86_64") then
            os.cp("bin", package:installdir())
            os.cp("include", package:installdir())
            os.cp("lib", package:installdir())
            package:addenv("PATH", "bin")
        end
    end)

    on_install("linux", "mingw", function (package)
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
