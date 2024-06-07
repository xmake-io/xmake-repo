package("amgx")

    set_homepage("https://developer.nvidia.com/amgx")
    set_description("Distributed multigrid linear solver library on GPU")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/NVIDIA/AMGX.git")
    add_versions("v2.4.0", "2b4762f02af2ed136134c7f0570646219753ab3e")

    add_patches("2.4.0", "patches/2.4.0/msvc.patch", "46dcb9a5e1b4157fce91e06050c1d70f5e4fe34d7bf085216629c4f8708f90a5")

    if is_plat("windows") then
        set_policy("platform.longpaths", true)
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake", "openmp")
    on_load("windows", function (package)
        package:add("deps", "cuda", {system = true, configs = {utils = {"cublas", "cusparse", "cusolver"}}})
        if not package:config("shared") then
            package:add("defines", "AMGX_API_NO_IMPORTS")
        end
    end)

    on_load("linux", function (package)
        package:add("deps", "cuda", {system = true, configs = {utils = {"cublas", "cusparse", "cusolver"}}})
        package:add("deps", "nvtx")
        package:add("syslinks", "pthread", "m")
    end)

    on_install("windows", "linux", function (package)
        io.replace("CMakeLists.txt", "/Zl", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(examples)", "", {plain = true})
        local configs = {"-DCMAKE_NO_MPI=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
        package:add("links", package:config("shared") and "amgxsh" or "amgx")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("AMGX_initialize", {includes = "amgx_c.h"}))
    end)
