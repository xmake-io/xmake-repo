package("scotch")
    set_homepage("https://www.labri.fr/perso/pelegrin/scotch/")
    set_description("Scotch: a software package for graph and mesh/hypergraph partitioning, graph clustering, and sparse matrix ordering")

    add_urls("https://gitlab.inria.fr/scotch/scotch/-/archive/$(version)/scotch-$(version).zip",
             "https://gitlab.inria.fr/scotch/scotch.git")

    add_versions("v6.1.1", "21d001c390ec63ac60f987b9921f33cc1967b41cf07567e22cbf3253cda8962a")
    add_versions("v7.0.5", "fd52e97844115dce069220bacbfb45fccdf83d425614b02b67b44cedf9d72640")

    if is_plat("windows", "mingw", "msys", "bsd") then
        add_patches("7.0.5", "patches/7.0.5/cmake.patch", "5104181d78dcf31779ab70cae61bb80fa2f6f836ce5d73628ef9b2d074fb8d8c")
    end

    add_configs("zlib", {description = "Use ZLIB compression format.", default = true, type = "boolean"})
    add_configs("lzma", {description = "Use LZMA compression format.", default = false, type = "boolean"})
    add_configs("bz2", {description = "Use BZ2 compression format.", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_links("ptesmumps", "esmumps", "scotch", "scotcherr", "scotcherrexit", "scotchmetis", "scotchmetisv5", "scotchmetisv3")

    if on_check then
        on_check(function (package)
            if package:is_cross() then
                raise("package(scotch) unsupported cross-compilation")
            end
        end)
    end

    on_load(function (package)
        if package:gitref() or package:version():ge("7.0.0") then
            package:add("deps", "cmake")
            package:add("deps", "flex", "bison")
            if package:is_plat("linux", "macosx") then
                package:add("deps", "gfortran", {kind = "binary"})
            end

            if package:config("zlib") then
                package:add("deps", "zlib")
            end
            if package:config("lzma") then
                package:add("deps", "xz")
            end
            if package:config("bz2") then
                package:add("deps", "bzip2")
            end
        else
            package:add("deps", "zlib")
        end
    end)
    -- mingw require to fix xrepo flex package
    on_install("windows|x64", "windows|arm64", "linux", "macosx", "bsd", function (package)
        if package:gitref() or package:version():ge("7.0.0") then
            local configs = {"-DENABLE_TESTS=OFF", "-DBUILD_PTSCOTCH=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DUSE_ZLIB=" .. (package:config("zlib") and "ON" or "OFF"))
            table.insert(configs, "-DUSE_LZMA=" .. (package:config("lzma") and "ON" or "OFF"))
            table.insert(configs, "-DUSE_BZ2=" .. (package:config("bz2") and "ON" or "OFF"))
            if package:is_plat("windows") then
                os.mkdir(path.join(package:buildir(), "src/scotch/pdb"))
                os.mkdir(path.join(package:buildir(), "src/esmumps/pdb"))
                os.mkdir(path.join(package:buildir(), "src/libscotch/pdb"))
                os.mkdir(path.join(package:buildir(), "src/libscotchmetis/pdb"))
                if package:config("shared") then
                    table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
                end
            end
            import("package.tools.cmake").install(package, configs)
        elseif package:is_plat("macosx", "linux") then
            import("package.tools.make")

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
            local envs = make.buildenvs(package)
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
            make.make(package, {"scotch"}, {envs = envs})
            make.make(package, {"esmumps"}, {envs = envs})
            make.make(package, {"prefix=" .. package:installdir(), "install"}, {envs = envs})

        else
            raise("Unsupported platform!")
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SCOTCH_graphInit", {includes = {"stdio.h", "stdlib.h", "scotch.h"}}))
    end)
