package("hypre")

    set_homepage("https://computing.llnl.gov/projects/hypre-scalable-linear-solvers-multigrid-methods")
    set_description("Parallel solvers for sparse linear systems featuring multigrid methods.")
    set_license("Apache-2.0")

    add_urls("https://github.com/hypre-space/hypre/archive/refs/tags/$(version).tar.gz",
             "https://github.com/hypre-space/hypre.git")
    add_versions("v2.20.0", "5be77b28ddf945c92cde4b52a272d16fb5e9a7dc05e714fc5765948cba802c01")
    add_versions("v2.23.0", "8a9f9fb6f65531b77e4c319bf35bfc9d34bf529c36afe08837f56b635ac052e2")

    add_configs("blas", {description = "Choose BLAS library to use.", default = "openblas", type = "string", values = {"mkl", "openblas"}})
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    on_load("windows", "macosx", "linux", function (package)
        package:add("deps", package:config("blas"))
    end)

    on_install("windows", "linux", "macosx", function (package)
        os.cd("src")
        local configs = {"-DHYPRE_WITH_MPI=OFF", "-DHYPRE_BUILD_EXAMPLES=OFF", "-DHYPRE_BUILD_TESTS=OFF", "-DHYPRE_USING_HYPRE_BLAS=OFF", "-DHYPRE_USING_HYPRE_LAPACK=OFF"}
        table.insert(configs, "-DHYPRE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DHYPRE_ENABLE_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("HYPRE_Init", {includes = "HYPRE_utilities.h"}))
    end)
