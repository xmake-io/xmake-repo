package("geos")

    set_homepage("https://trac.osgeo.org/geos/")
    set_description("GEOS (Geometry Engine - Open Source) is a C++ port of the ​JTS Topology Suite (JTS).")
    set_license("LGPL-2.1")

    add_urls("http://download.osgeo.org/geos/geos-$(version).tar.bz2")
    add_versions("3.9.1", "7e630507dcac9dc07565d249a26f06a15c9f5b0c52dd29129a0e3d381d7e382a")

    add_deps("cmake")
    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_BENCHMARKS=OFF", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("initGEOS", {includes = "geos_c.h"}))
    end)
