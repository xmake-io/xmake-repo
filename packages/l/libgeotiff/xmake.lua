package("libgeotiff")

    set_homepage("https://github.com/OSGeo/libgeotiff")
    set_description("Libgeotiff is an open source library for reading and writing GeoTIFF information tags")
    set_license("MIT")

    add_urls("https://download.osgeo.org/geotiff/libgeotiff/libgeotiff-$(version).tar.gz")
    add_versions("1.7.1", "05ab1347aaa471fc97347d8d4269ff0c00f30fa666d956baba37948ec87e55d6")

    add_configs("utils", {description = "Choose if GeoTIFF utilities should be built", default = false, type = "boolean"})

    add_deps("cmake", "libtiff")
    add_deps("proj", {configs = {tiff = true}})
    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DHAVE_TIFFOPEN=1", "-DHAVE_TIFFMERGEFIELDINFO=1"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_UTILITIES=" .. (package:config("utils") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("GTIFNew", {includes = "geotiff.h"}))
    end)
