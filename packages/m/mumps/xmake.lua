package("mumps")

    set_homepage("http://mumps.enseeiht.fr/")
    set_description("MUMPS: MUltifrontal Massively Parallel sparse direct Solver")

    add_urls("http://mumps.enseeiht.fr/MUMPS_$(version).tar.gz")
    add_versions("5.4.1", "93034a1a9fe0876307136dcde7e98e9086e199de76f1c47da822e7d4de987fa8")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("scotch", "openblas")
    if is_plat("linux") then
        add_syslinks("pthread")
    end
    add_links("smumps", "dmumps", "cmumps", "zmumps", "mumps_common", "pord", "mpiseq")
    on_install("linux", function (package)
        import("lib.detect.find_tool")
        local fortranc = find_tool("gfortran")
        if not fortranc then
            raise("gfortran not found!")
        end

        os.cp("Make.inc/Makefile.inc.generic.SEQ", "Makefile.inc")
        io.replace("Makefile.inc", "ORDERINGSF  = -Dpord", "ORDERINGSF  = -Dscotch -Dpord", {plain = true})
        io.replace("Makefile.inc", "LAPACK = -llapack", "LAPACK = -lopenblas", {plain = true})
        io.replace("Makefile.inc", "LIBBLAS = -lblas", "LIBBLAS = -lopenblas", {plain = true})
        io.replace("Makefile.inc", "f90", fortranc.program, {plain = true})
        io.replace("Makefile.inc", "OPTF    = -O", "OPTF    = -O -std=legacy", {plain = true})
        local envs = import("package.tools.make").buildenvs(package)
        local cflags, ldflags
        for _, dep in ipairs(package:orderdeps()) do
            local fetchinfo = dep:fetch()
            if fetchinfo then
                for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    cflags = (cflags or "") .. " -I" .. includedir
                end
                for _, linkdir in ipairs(fetchinfo.linkdirs) do
                    ldflags = (ldflags or "") .. " -L" .. linkdir
                end
            end
        end
        ldflags = (ldflags or "") .. " -lesmumps -lscotch -lscotcherr"
        envs.ISCOTCH = cflags
        envs.LSCOTCH = ldflags
        os.vrunv("make", {"all"}, {envs = envs})
        os.cp("include/*.h", package:installdir("include"))
        os.cp("lib/*.a|README", package:installdir("lib"))
        os.cp("libseq/*.a", package:installdir("lib"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dmumps_c", {includes = {"dmumps_c.h"}}))
    end)
