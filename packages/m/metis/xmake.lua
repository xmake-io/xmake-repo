package("metis")
    set_homepage("http://glaros.dtc.umn.edu/gkhome/metis/metis/overview")
    set_description("Serial Graph Partitioning and Fill-reducing Matrix Ordering")
    set_license("Apache-2.0")

    add_urls("https://github.com/KarypisLab/METIS/archive/refs/tags/$(version).tar.gz",
             "https://github.com/KarypisLab/METIS.git")

    add_versions("v5.2.1", "1a4665b2cd07edc2f734e30d7460afb19c1217c2547c2ac7bf6e1848d50aff7a")

    add_configs("long_index", {description = "Use 64-bit uint as index.", default = false, type = "boolean"})
    add_configs("double", {description = "Use double precision floats.", default = true, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_deps("gklib")

    on_install("!iphoneos", function (package)
        local idx_width = package:config("long_index") and 64 or 32
        io.gsub(path.join("include", "metis.h"), "//#define IDXTYPEWIDTH %d+", "#define IDXTYPEWIDTH " .. idx_width)
        local real_width = package:config("double") and 64 or 32
        io.gsub(path.join("include", "metis.h"), "//#define REALTYPEWIDTH %d+", "#define REALTYPEWIDTH " .. real_width)

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {tools = package:config("tools")})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("METIS_SetDefaultOptions", {includes = "metis.h"}))
    end)
