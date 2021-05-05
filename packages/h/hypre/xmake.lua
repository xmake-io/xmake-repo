package("hypre")

    set_homepage("https://computing.llnl.gov/projects/hypre-scalable-linear-solvers-multigrid-methods")
    set_description("Parallel solvers for sparse linear systems featuring multigrid methods.")
    set_license("Apache-2.0")

    add_urls("https://github.com/hypre-space/hypre/archive/refs/tags/$(version).tar.gz",
             "https://github.com/hypre-space/hypre.git")
    add_versions("v2.20.0", "5be77b28ddf945c92cde4b52a272d16fb5e9a7dc05e714fc5765948cba802c01")

    add_deps("cmake")
    on_install("windows", "linux", "macosx", function (package)
        os.cd("src")
        local configs = {"-DHYPRE_WITH_MPI=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DHYPRE_ENABLE_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("HYPRE_Init", {includes = "HYPRE_utilities.h"}))
    end)
