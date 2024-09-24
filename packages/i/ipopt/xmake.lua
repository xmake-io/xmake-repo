package("ipopt")
    set_homepage("https://github.com/coin-or/Ipopt")    
    set_description("Ipopt (Interior Point OPTimizer, pronounced eye-pea-Opt) is a software package for large-scale nonlinear optimization.")
    set_license("EGPL-2.0")

    add_urls("https://github.com/coin-or/Ipopt/archive/refs/tags/releases/3.14.16.tar.gz")
    add_versions("3.14.16", "cc8c217991240db7eb14189eee0dff88f20a89bac11958b48625fa512fe8d104")

    if is_plat("linux") then
        add_extsources("apt::liblapack-dev")
        add_syslinks("gfortran", "pthread")
    end

    add_deps("gfortran", "openblas", "mumps", "coin-or-asl")

    if not is_plat("windows") then
        add_deps("autoconf", "automake", "libtool", "m4")
    end

    add_links("smumps", "dmumps", "cmumps", "zmumps", "mumps_common", "esmumps", "pord", "mpiseq", "ptesmumps", "esmumps", "scotch", "scotcherr", 
            "scotcherrexit", "scotchmetisv5", "scotchmetisv3", "gfortran", "dl")

    add_includedirs("include", "include/coin-or")
    add_linkdirs("lib")

    on_install("linux", function (package)
        local fetch_info_mumps = package:dep("mumps"):fetch()

        local configs = {"-with-PACKAGE=yes"}
        
        table.insert(configs, [[--with-mumps-cflags="-I]] .. fetch_info_mumps.sysincludedirs[1] .. [["]])

        local mumps_lflags = [[--with-mumps-lflags= "]]
        for _, link in ipairs(fetch_info_mumps.links) do 
            mumps_lflags = mumps_lflags .. "-l" .. link .. " "
        end        
        mumps_lflags = mumps_lflags  .. [[-lesmumps -lscotch -lscotcherr -lscotcherrexit -lscotchmetisv5 -lscotchmetisv3 -lgfortran -lpthread"]]

        table.insert(configs, mumps_lflags)

        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs, {packagedeps={"mumps", "gfortran", "scotch"}})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "IpIpoptApplication.hpp"
            #include "IpSolveStatistics.hpp"

            using namespace Ipopt;

            void test() {
                SmartPtr<IpoptApplication> app = IpoptApplicationFactory();
                ApplicationReturnStatus status;
                status = app->Initialize();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "IpIpoptApplication.hpp"}))
    end)
