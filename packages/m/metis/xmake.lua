package("metis")
    set_homepage("http://glaros.dtc.umn.edu/gkhome/metis/metis/overview")
    set_description("Serial Graph Partitioning and Fill-reducing Matrix Ordering")
    set_license("Apache-2.0")

    add_urls("https://github.com/KarypisLab/METIS/archive/refs/tags/$(version).tar.gz",
             "https://github.com/KarypisLab/METIS.git")

    add_versions("v5.2.1", "1a4665b2cd07edc2f734e30d7460afb19c1217c2547c2ac7bf6e1848d50aff7a")

    add_patches("5.2.1", "patches/5.2.1/gklib.patch", "63e5035241f23ee664800ec1811ea8baa69895c71ec007ab1a95103a290c11eb")
    add_resources("5.2.1", "gklib", "https://github.com/KarypisLab/GKlib.git", "8bd6bad750b2b0d90800c632cf18e8ee93ad72d7")

    add_configs("long_index", {description = "Use 64-bit uint as index.", default = false, type = "boolean"})
    add_configs("double", {description = "Use double precision floats.", default = true, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("m")
    end

    add_deps("cmake")

    on_install(function (package)
        local idx_width = package:config("long_index") and 64 or 32
        io.gsub(path.join("include", "metis.h"), "//#define IDXTYPEWIDTH %d+", "#define IDXTYPEWIDTH " .. idx_width)
        local real_width = package:config("double") and 64 or 32
        io.gsub(path.join("include", "metis.h"), "//#define REALTYPEWIDTH %d+", "#define REALTYPEWIDTH " .. real_width)
        io.replace(path.join(package:resourcefile("gklib"), "gk_arch.h"), "gk_ms_stdint.h", "stdint.h", {plain = true})
        io.replace(path.join(package:resourcefile("gklib"), "gk_arch.h"), "gk_ms_inttypes.h", "inttypes.h", {plain = true})

        io.replace("libmetis/CMakeLists.txt", "RUNTIME DESTINATION lib", "RUNTIME DESTINATION bin", {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DDEBUG=" .. (package:debug() and "ON" or "OFF"))
        table.insert(configs, "-DSHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DGKLIB_PATH=" .. package:resourcefile("gklib"):gsub("\\", "/"))
        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
            if package:config("shared") then
                table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("METIS_SetDefaultOptions", {includes = "metis.h"}))
    end)
