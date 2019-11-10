package("libtiff")

    set_homepage("http://www.simplesystems.org/libtiff/")
    set_description("TIFF Library and Utilities.")

    set_urls("https://download.osgeo.org/libtiff/tiff-$(version).tar.gz",
             "https://fossies.org/linux/misc/tiff-$(version).tar.gz")
    add_versions("4.1.0", "5d29f32517dadb6dbcd1255ea5bbc93a2b54b94fbf83653b4d65c7d6775b8634")

    add_links("tiff")

    if is_plat("windows") then
        add_deps("cmake")
    end

    on_install("windows", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--disable-dependency-tracking", "--disable-lzma", "--without-x"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("TIFFOpen", {includes = "tiffio.h"}))
    end)
