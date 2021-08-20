package("mpich")

    set_homepage("https://www.mpich.org/")
    set_description("MPICH is a high performance and widely portable implementation of the Message Passing Interface (MPI) standard.")

    add_urls("http://www.mpich.org/static/downloads/$(version)/mpich-$(version).tar.gz")
    add_versions("3.4.2", "5c19bea8b84e8d74cca5f047e82b147ff3fba096144270e3911ad623d6c587bf")

    add_configs("device", {description = "Specify the communication device for MPICH.", default = "ofi", type = "string", values = {"ofi", "ucx"}})
    add_configs("x11", {description = "Use the X Window System.", default = false, type = "boolean"})

    if is_plat("linux") then
        add_extsources("apt::libmpich-dev")
        add_syslinks("pthread", "dl", "rt")
    end

    add_deps("hwloc")
    on_load("macosx", "linux", function (package)
        if package:config("x11") then
            package:add("deps", "libx11")
            package:add("deps", "libxnvctrl", {system = true, optional = true})
        end
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--disable-fortran",
                         "--without-slurm",
                         "--without-xpmem",
                         "--without-hcoll",
                         "--without-blcr",
                         "--without-papi",
                         "--without-pmix"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        table.insert(configs, "--with-device=ch4:" .. package:config("device"))
        table.insert(configs, "--with-hwloc-prefix=" .. package:dep("hwloc"):installdir())
        table.insert(configs, "--with-x=" .. (package:config("x11") and "yes" or "no"))
        import("package.tools.autoconf").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        os.vrun("mpicc --version")
        assert(package:has_cfuncs("MPI_Init", {includes = "mpi.h"}))
    end)
