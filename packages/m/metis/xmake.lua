package("metis")

    set_homepage("http://glaros.dtc.umn.edu/gkhome/metis/metis/overview")
    set_description("Serial Graph Partitioning and Fill-reducing Matrix Ordering")
    set_license("Apache-2.0")

    add_urls("https://github.com/KarypisLab/METIS/archive/refs/tags/$(version).tar.gz")
    add_versions("v5.2.1", "1a4665b2cd07edc2f734e30d7460afb19c1217c2547c2ac7bf6e1848d50aff7a")

    add_patches("5.2.1", "patches/5.2.1/gklib.patch", "5a8067e15681d4a1fd1da0307effcafdaa491a314558df803457dff21602b566")
    add_resources("5.2.1", "gklib", "https://github.com/KarypisLab/GKlib.git", "8bd6bad750b2b0d90800c632cf18e8ee93ad72d7")

    add_configs("long_index", {description = "Use 64-bit uint as index.", default = false, type = "boolean"})
    add_configs("double", {description = "Use double precision floats.", default = true, type = "boolean"})

    add_deps("cmake")
    if is_plat("linux") then
        add_syslinks("m")
    end
    on_install("windows", "macosx", "linux", function (package)
        local idx_width = package:config("long_index") and 64 or 32
        io.gsub(path.join("include", "metis.h"), "//#define IDXTYPEWIDTH %d+", "#define IDXTYPEWIDTH " .. idx_width)
        local real_width = package:config("double") and 64 or 32
        io.gsub(path.join("include", "metis.h"), "//#define REALTYPEWIDTH %d+", "#define REALTYPEWIDTH " .. real_width)

        local configs = {}
        table.insert(configs, "-DDEBUG=" .. (package:debug() and "ON" or "OFF"))
        table.insert(configs, "-DSHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DGKLIB_PATH=" .. package:resourcefile("gklib"):gsub("\\", "/"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("METIS_SetDefaultOptions", {includes = "metis.h"}))
    end)
