package("scotch")

    set_homepage("https://www.labri.fr/perso/pelegrin/scotch/")
    set_description("Scotch: a software package for graph and mesh/hypergraph partitioning, graph clustering, and sparse matrix ordering")

    add_urls("https://gitlab.inria.fr/scotch/scotch/-/archive/$(version)/scotch-$(version).zip",
             "https://gitlab.inria.fr/scotch/scotch.git")
    add_versions("v6.1.1", "21d001c390ec63ac60f987b9921f33cc1967b41cf07567e22cbf3253cda8962a")

    add_deps("zlib")
    if is_plat("linux") then
        add_syslinks("pthread")
    end
    add_links("esmumps", "scotch", "scotcherr", "scotcherrexit", "scotchmetis")
    on_install("macosx|x86_64", "linux", function (package)
        os.cd("src")
        if package:is_plat("macosx") then
            os.cp("Make.inc/Makefile.inc.i686_mac_darwin10", "Makefile.inc")
        elseif package:is_plat("linux") then
            local basename
            if package:is_arch("x86_64") then
                basename = "Make.inc/Makefile.inc.x86-64_pc_linux2"
            elseif package:is_arch("i386", "x86") then
                basename = "Make.inc/Makefile.inc.i686_pc_linux2"
            end
            os.cp(basename .. (package:config("shared") and ".shlib" or ""), "Makefile.inc")
        end
        io.replace("Makefile.inc", "CFLAGS%s+=", "CFLAGS := $(CFLAGS)")
        io.replace("Makefile.inc", "LDFLAGS%s+=", "LDFLAGS := $(LDFLAGS)")
        local envs = import("package.tools.make").buildenvs(package)
        local zlib = package:dep("zlib"):fetch()
        if zlib then
            local cflags, ldflags
            for _, includedir in ipairs(zlib.sysincludedirs or zlib.includedirs) do
                cflags = (cflags or "") .. " -I" .. includedir
            end
            for _, linkdir in ipairs(zlib.linkdirs) do
                ldflags = (ldflags or "") .. " -L" .. linkdir
            end
            envs.CFLAGS  = cflags
            envs.LDFLAGS = ldflags
        end
        os.vrunv("make", {"scotch"}, {envs = envs})
        os.vrunv("make", {"esmumps"}, {envs = envs})
        os.vrunv("make", {"prefix=" .. package:installdir(), "install"}, {envs = envs})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SCOTCH_graphInit", {includes = {"stdio.h", "stdlib.h", "scotch.h"}}))
    end)
