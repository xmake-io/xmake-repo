package("h3")
    set_homepage("https://h3geo.org")
    set_description("Hexagonal hierarchical geospatial indexing system")
    set_license("Apache-2.0")

    add_urls("https://github.com/uber/h3/archive/refs/tags/$(version).tar.gz",
             "https://github.com/uber/h3.git")

    add_versions("v4.3.0", "a47cfa36e255e4bf16c63015aaff8e6fe2afc14ffaa3f6b281718158446c0e9b")

    add_configs("filters", {description = "Build filters.", default = true, type = "boolean"})

    add_deps("cmake")

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    on_install(function (package)
        local configs = {
            "-DENABLE_COVERAGE=OFF",
            "-DENABLE_DOCS=OFF",
            "-DENABLE_FORMAT=OFF",
            "-DENABLE_LINTING=OFF",
            "-DBUILD_BENCHMARKS=OFF",
            "-DBUILD_FUZZERS=OFF",
            "-DBUILD_GENERATORS=OFF",
            "-DBUILD_TESTING=OFF",
            "-DWARNINGS_AS_ERRORS=OFF"
        }
        table.insert(configs, "-DBUILD_FILTERS=" .. (package:config("filters") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("radsToDegs", {includes = "h3/h3api.h"}))
    end)
