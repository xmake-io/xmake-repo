package("metis")

    set_homepage("http://glaros.dtc.umn.edu/gkhome/metis/metis/overview")
    set_description("Serial Graph Partitioning and Fill-reducing Matrix Ordering")

    add_urls("https://github.com/xq114/METIS/archive/v$(version).tar.gz")
    add_versions("5.1.1", "945d381d3b50ca70ac93f0daf32c80e6f16f11514879d5ff1438aa82c20a0ba5")

    add_deps("cmake")
    add_configs("long_index", {description = "Use 64-bit uint as index.", default = false, type = "boolean"})
    add_configs("double", {description = "Use double precision floats.", default = true, type = "boolean"})

    on_install("windows", "macosx", "linux", function (package)
        if package:config("long_index") then
            io.gsub(path.join("include", "metis.h"), "define IDXTYPEWIDTH %d+", "define IDXTYPEWIDTH 64")
        end
        if package:config("double") then
            io.gsub(path.join("include", "metis.h"), "define REALTYPEWIDTH %d+", "define REALTYPEWIDTH 64")
        end
        local configs = {}
        table.insert(configs, "-DSHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DDEBUG=" .. (package:debug() and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("METIS_SetDefaultOptions", {includes = "metis.h"}))
    end)
