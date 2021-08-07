package("starpu")

    set_homepage("https://starpu.gitlabpages.inria.fr/")
    set_description("StarPU is a task programming library for hybrid architectures")
    set_license("LGPL-2.1")

    add_urls("https://files.inria.fr/starpu/starpu-$(version)/starpu-$(version).tar.gz")
    add_versions("1.3.8", "d35a27b219af8e7973888ebbff728ec0112ae9cda88d6b79c4cc7a1399b4d052")

    add_deps("hwloc")
    if is_plat("linux") then
        add_syslinks("pthread", "rt")
    end

    on_load("macosx", "linux", function (package)
        package:add("includedirs", format("include/starpu/%d.%d", package:version():major(), package:version():minor()))
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--disable-build-doc", "--disable-build-tests", "--disable-build-examples", "--disable-fortran"}
        if package:is_plat("macosx") then
            -- OpenCL is deprecated on Mac OS X
            table.insert(configs, "--disable-opencl")
        end
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
            table.insert(configs, "--enable-static=no")
        else
            table.insert(configs, "--enable-shared=no")
            table.insert(configs, "--enable-static=yes")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("starpu_task_get_current", {includes = "starpu.h"}))
    end)
