package("imagemagick")
    set_homepage("https://imagemagick.org/script/index.php")
    set_description("ImageMagick is a FOSS software suite for modifying images. This does NOT provide any of the utilities. It installs the C/C++ Libraries.")
    add_urls("https://download.imagemagick.org/ImageMagick/download/ImageMagick-$(version).tar.gz")
    add_versions("7.0.11-13", "6c162d7cbd7b80968a6d083d39eb18d9c9bbd49f500f7f49c9a5dcc0fc36a03b")
    add_deps("pkg-config")
    add_deps("ffmpeg", "fftw", "jasper", "libjpeg-turbo", "libpng", "libtiff", "libwebp", "openjpeg", "openexr", "zlib", {optional = true})
    add_includedirs("include/ImageMagick-7")

    on_install("bsd", "linux", "macosx", function(package)
        local configs = {"--with-utilities=no", "--with-x=no"}
         table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no")) 
         table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes")) 
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("MagickWandGenesis", {includes = "MagickWand/MagickWand.h"}))
    end)
