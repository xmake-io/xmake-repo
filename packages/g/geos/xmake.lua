package("geos")
    set_homepage("https://trac.osgeo.org/geos/")
    set_description("GEOS (Geometry Engine - Open Source) is a C++ port of the JTS Topology Suite (JTS).")
    set_license("LGPL-2.1")

    add_urls("https://github.com/libgeos/geos/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libgeos/geos.git")

    add_versions("3.14.1", "512118b3be3ccefbca66b36b0f3e895576d08d6ff330ba1511a31a306abbb477")
    add_versions("3.14.0", "47dbfad4e90073c7593ae5cfd560bc961f049af2b6868882cc1e7a9b9885a22c")
    add_versions("3.13.1", "724788988fa32a59b3853b876b3d865595c11dfcda7883e4e6a78e44334ac8ce")
    add_versions("3.13.0", "351375d3697000d94a6b3d4041f08e12221f4eb065ed412c677960a869518631")
    add_versions("3.12.1", "f6e2f3aaa417410d3fa4c78a9c5ef60d46097ef7ad0aee3bbbb77327350e1e01")
    add_versions("3.11.3", "3c517fcccdd3d562122d59c93e0982ef9bc10e775a177ad88882fca1d7d28d08")
    add_versions("3.9.1", "e9e20e83572645ac2af0af523b40a404627ce74b3ec99727754391cdf5b23645")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_links("geos_c", "geos")

    add_deps("cmake")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk"):config("ndkver")
            assert(ndk and tonumber(ndk) > 22, "package(geos) require ndk version > 22")
        end)
    end

    on_install(function (package)
        local configs = {"-DBUILD_BENCHMARKS=OFF", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_GEOSOP=" .. (package:config("tools") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("initGEOS", {includes = "geos_c.h"}))
    end)
