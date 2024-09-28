package("superlu")

    set_homepage("https://portal.nersc.gov/project/sparse/superlu/")
    set_description("SuperLU is a general purpose library for the direct solution of large, sparse, nonsymmetric systems of linear equations.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/xiaoyeli/superlu/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xiaoyeli/superlu.git")
    add_versions("v5.2.2", "470334a72ba637578e34057f46948495e601a5988a602604f5576367e606a28c")
    add_versions("v5.3.0", "3e464afa77335de200aeb739074a11e96d9bef6d0b519950cfa6684c4be1f350")
    add_versions("v7.0.0", "d7b91d4e0bb52644ca74c1a4dd466a694ddf1244a7bbf93cb453e8ca1f6527eb")

    add_configs("blas", {description = "Choose BLAS library to use.", default = "openblas", type = "string", values = {"mkl", "openblas"}})

    on_load("windows|!arm64", "linux", "macosx", function (package)
        package:add("deps", package:config("blas"))
    end)

    on_install("windows|!arm64", "linux", "macosx", function (package)
        os.cd("SRC")
        if package:version():ge("7.0.0") then
            io.replace("superlu_config.h", "#define HAVE_METIS TRUE", "", {plain = true})
        end
        io.writefile("xmake.lua", format([[
            add_rules("mode.debug", "mode.release")
            add_rules("utils.install.cmake_importfiles")
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
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dCreate_Dense_Matrix", {includes = "slu_ddefs.h"}))
    end)
