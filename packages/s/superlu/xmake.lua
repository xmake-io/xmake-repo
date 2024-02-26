package("superlu")

    set_homepage("https://portal.nersc.gov/project/sparse/superlu/")
    set_description("SuperLU is a general purpose library for the direct solution of large, sparse, nonsymmetric systems of linear equations.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/xiaoyeli/superlu/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xiaoyeli/superlu.git")
    add_versions("v6.0.1", "6c5a3a9a224cb2658e9da15a6034eed44e45f6963f5a771a6b4562f7afb8f549")
    add_versions("v5.2.2", "470334a72ba637578e34057f46948495e601a5988a602604f5576367e606a28c")
    add_versions("v5.3.0", "3e464afa77335de200aeb739074a11e96d9bef6d0b519950cfa6684c4be1f350")

    add_configs("blas", {description = "Choose BLAS library to use.", default = "mkl", type = "string", values = {"mkl", "openblas"}})

    on_load("windows", "linux", "macosx", function (package)
        package:add("deps", package:config("blas"))
    end)

    on_install("windows", "linux", "macosx", function (package)
        os.cd("SRC")
        io.writefile("xmake.lua", format([[
            add_rules("mode.debug", "mode.release")
            add_requires("%s")
            target("superlu")
                set_kind("$(kind)")
                add_defines("USE_VENDOR_BLAS")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
                add_files("*.c")
                add_includedirs(".")
                add_headerfiles("*.h")
                add_packages("%s")
        ]], package:config("blas"), package:config("blas")))
        local configs = {kind = package:config("shared") and "shared" or "static"}
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dCreate_Dense_Matrix", {includes = "slu_ddefs.h"}))
    end)
