package("plfit")
    set_homepage("https://github.com/ntamas/plfit")
    set_description("Fitting power-law distributions to empirical data, according to the method of Clauset, Shalizi and Newman")
    set_license("GPL-2.0")

    add_urls("https://github.com/ntamas/plfit/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ntamas/plfit.git")

    add_versions("1.0.0", "b64eff580c721809d32be69c43070c37c9200ca02e5169d9ae7972fbd759977e")

    add_configs("sse", {description = "Use SSE/SSE2 optimizations if available", default = false, type = "boolean"})
    add_configs("openmp", {description = "Use OpenMP parallelization if available (experimental)", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("openmp") then
            package:add("deps", "openmp")
        end

        if not package:config("shared") then
            package:add("defines", "PLFIT_STATIC")
        end
    end)

    on_install("!cross", function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(test)", "", {plain = true})
        if package:is_plat("cross", "wasm") then
            io.replace("CMakeLists.txt", "FIND_LIBRARY(MATH_LIBRARY NAMES m)", "set(MATH_LIBRARY )", {plain = true})
        end

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DPLFIT_ENABLE_LTO=" .. (package:config("lto") and "ON" or "OFF"))

        table.insert(configs, "-DPLFIT_USE_SSE=" .. (package:config("sse") and "ON" or "OFF"))
        table.insert(configs, "-DPLFIT_USE_OPENMP=" .. (package:config("openmp") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("plfit_continuous_options_init", {includes = "plfit/plfit.h"}))
    end)
