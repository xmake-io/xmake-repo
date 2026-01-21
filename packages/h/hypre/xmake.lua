package("hypre")
    set_homepage("https://computing.llnl.gov/projects/hypre-scalable-linear-solvers-multigrid-methods")
    set_description("Parallel solvers for sparse linear systems featuring multigrid methods.")
    set_license("Apache-2.0")

    add_urls("https://github.com/hypre-space/hypre/archive/refs/tags/$(version).tar.gz",
             "https://github.com/hypre-space/hypre.git")

    add_versions("v2.33.0", "0f9103c34bce7a5dcbdb79a502720fc8aab4db9fd0146e0791cde7ec878f27da")
    add_versions("v2.32.0", "2277b6f01de4a7d0b01cfe12615255d9640eaa02268565a7ce1a769beab25fa1")
    add_versions("v2.31.0", "9a7916e2ac6615399de5010eb39c604417bb3ea3109ac90e199c5c63b0cb4334")
    add_versions("v2.30.0", "8e2af97d9a25bf44801c6427779f823ebc6f306438066bba7fcbc2a5f9b78421")
    add_versions("v2.20.0", "5be77b28ddf945c92cde4b52a272d16fb5e9a7dc05e714fc5765948cba802c01")
    add_versions("v2.23.0", "8a9f9fb6f65531b77e4c319bf35bfc9d34bf529c36afe08837f56b635ac052e2")

    add_configs("blas", {description = "Choose BLAS library to use.", default = "openblas", type = "string", values = {"mkl", "openblas"}})
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    on_load(function (package)
        package:add("deps", package:config("blas"))
    end)

    on_install("windows|x86", "windows|x64", "linux", "macosx", function (package)
        os.cd("src")

        local configs = {
            "-DHYPRE_BUILD_EXAMPLES=OFF",
            "-DHYPRE_BUILD_TESTS=OFF",
            "-DHYPRE_WITH_MPI=OFF",
            "-DHYPRE_USING_HYPRE_BLAS=OFF",
            "-DHYPRE_USING_HYPRE_LAPACK=OFF",
            -- >=2.33
            "-DHYPRE_ENABLE_MPI=OFF",
            "-DHYPRE_ENABLE_HYPRE_BLAS=OFF",
            "-DHYPRE_ENABLE_HYPRE_LAPACK=OFF",
        }
        table.insert(configs, "-DHYPRE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DHYPRE_ENABLE_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local fn
        if package:version() and package:version():ge("2.29.0") then
            fn = "HYPRE_Initialize"
        else
            fn = "HYPRE_Init"
        end
        assert(package:has_cfuncs(fn, {includes = "HYPRE_utilities.h"}))
    end)
