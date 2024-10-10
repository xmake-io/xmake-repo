package("geos")

    set_homepage("https://trac.osgeo.org/geos/")
    set_description("GEOS (Geometry Engine - Open Source) is a C++ port of the JTS Topology Suite (JTS).")
    set_license("LGPL-2.1")

    add_urls("https://github.com/libgeos/geos/archive/refs/tags/$(version).tar.gz")
    add_versions("3.13.0", "351375d3697000d94a6b3d4041f08e12221f4eb065ed412c677960a869518631")
    add_versions("3.12.1", "f6e2f3aaa417410d3fa4c78a9c5ef60d46097ef7ad0aee3bbbb77327350e1e01")
    add_versions("3.11.3", "3c517fcccdd3d562122d59c93e0982ef9bc10e775a177ad88882fca1d7d28d08")
    add_versions("3.9.1", "e9e20e83572645ac2af0af523b40a404627ce74b3ec99727754391cdf5b23645")

    add_deps("cmake")
    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_BENCHMARKS=OFF", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("initGEOS", {includes = "geos_c.h"}))
    end)
