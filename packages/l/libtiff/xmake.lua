package("libtiff")

    set_homepage("http://www.simplesystems.org/libtiff/")
    set_description("TIFF Library and Utilities.")

    set_urls("https://download.osgeo.org/libtiff/tiff-$(version).tar.gz",
             "https://fossies.org/linux/misc/tiff-$(version).tar.gz")
    add_versions("4.1.0", "5d29f32517dadb6dbcd1255ea5bbc93a2b54b94fbf83653b4d65c7d6775b8634")

    add_deps("zlib")
    if is_plat("windows", "mingw") then
        add_deps("cmake")
    end

    on_install("windows", "mingw", function (package)
        local configs = {"-Dzstd=OFF", "-Dlzma=OFF", "-Dwebp=OFF", "-Djpeg12=OFF", "-Djbig=OFF", "-Dpixarlog=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--disable-dependency-tracking", "--disable-lzma", "--disable-webp", "--disable-jpeg", "--disable-zstd", "--disable-old-jpeg", "--disable-jbig", "--disable-pixarlog", "--without-x"}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
            table.insert(configs, "--enable-static=no")
        else
            table.insert(configs, "--enable-static=yes")
            table.insert(configs, "--enable-shared=no")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("TIFFOpen", {includes = "tiffio.h"}))
    end)
