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

    on_load(function (package)
        if package:config("x11") then
            package:add("deps", "libx11")
            package:add("deps", "libxnvctrl", {system = true, optional = true})
        end
        package:addenv("PATH", "bin")
    end)

    on_install("macosx", "linux", function (package)
        local configs = {
            "--disable-dependency-tracking",
            "--disable-fortran",
            "--without-slurm",
            "--without-xpmem",
            "--without-hcoll",
            "--without-blcr",
            "--without-papi",
            "--without-pmix"
        }
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--with-device=ch4:" .. package:config("device"))
        table.insert(configs, "--with-hwloc-prefix=" .. package:dep("hwloc"):installdir())
        table.insert(configs, "--with-x=" .. (package:config("x11") and "yes" or "no"))

        local opt = {}
        if package:is_plat("linux") then
            opt.ldflags = "-lm"
            opt.shflags = "-lm"
        end
        import("package.tools.autoconf").install(package, configs, opt)
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("mpicc --version")
        end
        assert(package:has_cfuncs("MPI_Init", {includes = "mpi.h"}))
    end)
