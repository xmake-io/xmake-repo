package("clblast")
    set_homepage("https://github.com/CNugteren/CLBlast")
    set_description("Tuned OpenCL BLAS ")
    set_license("Apache-2.0")

    add_urls("https://github.com/CNugteren/CLBlast/archive/$(version).tar.gz",
             "https://github.com/CNugteren/CLBlast.git")
    add_versions("1.6.0", "9bff8219f753262e2c3bb38eb74264dce8772f626ed59d0765851a4269532888")

    add_configs("tuners", { description = "Enable compilation of the tuners", default = false, type = "boolean" })
    add_configs("workaround", { description = "Enables workaround for bug in AMD Southern Island GPUs", default = false, type = "boolean" })
    add_configs("verbose", { description = "Compile in verbose mode for additional diagnostic messages", default = false, type = "boolean" })
    add_configs("opencl", { description = "Build CLBlast with an OpenCL API", default = true, type = "boolean" })
    add_configs("cuda", { description = "Build CLBlast with a CUDA API (beta)", default = false, type = "boolean" })
    add_configs("netlib", { description = "Enable compilation of the CBLAS Netlib API", default = false, type = "boolean" })
    add_configs("netlib_persistent_opencl", { description = "Makes OpenCL device and context in the CBLAS Netlib API static", default = false, type = "boolean" })

    add_deps("cmake")

    if is_plat("linux") then
        add_extsources("apt::libclblast-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::clblast")
    end

    on_load(function (package) 
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
        if package:config("opencl") then
           package:add("deps", "opencl")
        end
    end)

    on_install("windows|x86", "windows|x64", "linux", "macosx", function (package) 
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DTUNERS=" .. (package:config("tuners") and "ON" or "OFF"))
        table.insert(configs, "-DVERBOSE=" .. (package:config("verbose") and "ON" or "OFF"))
        table.insert(configs, "-DAMD_SI_EMPTY_KERNEL_WORKAROUND=" .. (package:config("workaround") and "ON" or "OFF"))
        table.insert(configs, "-DOPENCL=" .. (package:config("opencl") and "ON" or "OFF"))
        table.insert(configs, "-DCUDA=" .. (package:config("cuda") and "ON" or "OFF"))
        table.insert(configs, "-DNETLIB=" .. (package:config("cuda") and "ON" or "OFF"))
        table.insert(configs, "-DNETLIB_PERSISTENT_OPENCL=" .. (package:config("cuda") and "ON" or "OFF"))

        if package:is_plat("windows") and package:config("vs_runtime"):startswith("MT") then
            table.insert(configs,"-DOVERRIDE_MSVC_FLAGS_TO_MT=ON")
        end

        import("package.tools.cmake").install(package, configs)
    end)
