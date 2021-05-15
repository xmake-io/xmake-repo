package("superlu")

    set_homepage("https://portal.nersc.gov/project/sparse/superlu/")
    set_description("SuperLU is a general purpose library for the direct solution of large, sparse, nonsymmetric systems of linear equations.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/xiaoyeli/superlu/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xiaoyeli/superlu.git")
    add_versions("v5.2.2", "470334a72ba637578e34057f46948495e601a5988a602604f5576367e606a28c")

    add_configs("blas_vendor", {description = "Set BLAS vendor.", default = "mkl", type = "string", values = {"mkl", "openblas"}})

    on_load("windows", "linux", "macosx", function (package)
        package:add("deps", package:config("blas_vendor"))
    end)

    on_install("windows", "linux", "macosx", function (package)
        os.cd("SRC")
        io.writefile("xmake.lua", format([[
            add_rules("mode.debug", "mode.release")
            add_requires("%s")
            target("superlu")
                set_kind("$(kind)")
                add_defines("USE_VENDOR_BLAS")
                add_files("*.c")
                add_includedirs(".")
                add_headerfiles("*.h")
                add_packages("%s")
        ]], package:config("blas_vendor"), package:config("blas_vendor")))
        local configs = {kind = package:config("shared") and "shared" or "static"}
        if package:is_plat("windows") and package:config("shared") then
            raise("shared library is not supported on windows!")
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dCreate_Dense_Matrix", {includes = "slu_ddefs.h"}))
    end)
