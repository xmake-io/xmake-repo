package("coin-or-ipopt")
    set_homepage("https://github.com/coin-or/Ipopt")    
    set_description("Ipopt (Interior Point OPTimizer, pronounced eye-pea-Opt) is a software package for large-scale nonlinear optimization.")
    set_license("EGPL-2.0")

    add_urls("https://github.com/coin-or/Ipopt/archive/refs/tags/releases/$(version).tar.gz", 
             "https://github.com/coin-or/Ipopt.git")
    add_versions("3.14.16", "cc8c217991240db7eb14189eee0dff88f20a89bac11958b48625fa512fe8d104")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    add_deps("gfortran", "openblas", "mumps", "coin-or-asl", "lapack", "openmp")

    if not is_plat("windows") then
        add_deps("autoconf", "automake", "libtool", "m4")
    end

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_includedirs("include", "include/coin-or")

    on_install("linux", function (package)
        io.replace("configure", "ac_name=dsyev", "ac_name=LAPACKE_dsyev", {plain=true})
        io.replace("configure", "ac_name=DSYEV", "ac_name=LAPACKE_dsyev", {plain=true})
        io.replace("src/LinAlg/IpBlas.cpp", "IPOPT_BLAS_FUNC(s ## name,S ## NAME)", "IPOPT_BLAS_FUNC(s ## name ## _ ,S ## NAME ## _)", {plain=true})
        io.replace("src/LinAlg/IpBlas.cpp", "IPOPT_BLAS_FUNC(d ## name,D ## NAME)", "IPOPT_BLAS_FUNC(d ## name ## _,D ## NAME ## _)", {plain=true})
        io.replace("src/LinAlg/IpBlas.cpp", "IPOPT_BLAS_FUNC(idamax, IDAMAX)", "IPOPT_BLAS_FUNC(idamax_, IDAMAX_)", {plain=true})
        io.replace("src/LinAlg/IpLapack.cpp", "IPOPT_LAPACK_FUNC(s ## name,S ## NAME)", "IPOPT_LAPACK_FUNC(s ## name ## _,S ## NAME ## _)", {plain=true})
        io.replace("src/LinAlg/IpLapack.cpp", "IPOPT_LAPACK_FUNC(d ## name,D ## NAME)", "IPOPT_LAPACK_FUNC(d ## name ## _,D ## NAME ## _)", {plain=true})

        local fetch_info_mumps = package:dep("mumps"):fetch()
        local fetch_info_lapack = package:dep("lapack"):fetch()

        local configs = {}

        local lapack_flags = [[--with-lapack-lflags=-L]] .. tostring(fetch_info_lapack.linkdirs[1]) .. [[ ]]
        for _, link in ipairs(fetch_info_lapack.links) do 
            lapack_flags = lapack_flags .. "-l" .. tostring(link) .. " "
        end        
        lapack_flags = lapack_flags .. [[-lgfortran -lm -fopenmp]]
        table.insert(configs, lapack_flags)
        
        table.insert(configs, [[--with-mumps-cflags="-I]] .. fetch_info_mumps.sysincludedirs[1] .. [["]])
        local mumps_lflags = [[--with-mumps-lflags= "]]
        for _, link in ipairs(fetch_info_mumps.links) do 
            mumps_lflags = mumps_lflags .. "-l" .. link .. " "
        end        
        mumps_lflags = mumps_lflags  .. [[-lesmumps -lscotch -lscotcherr -lscotcherrexit -lscotchmetisv5 -lscotchmetisv3 -lpthread"]]
        table.insert(configs, mumps_lflags)

        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))

        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end

        import("package.tools.autoconf").install(package, configs, {packagedeps = {"mumps", "scotch", "lapack"}})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "IpIpoptApplication.hpp"
            #include "IpSolveStatistics.hpp"
            #include "IpBlas.hpp"

            using namespace Ipopt;

            void test() {
                IpBlasDot(0, nullptr, 0, nullptr, 0);
                SmartPtr<IpoptApplication> app = new IpoptApplication;
                ApplicationReturnStatus status;
                status = app->Initialize();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "IpIpoptApplication.hpp"}))
    end)
