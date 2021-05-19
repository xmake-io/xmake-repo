package("imagemagick")
    set_homepage("https://imagemagick.org/script/index.php")
    set_description("ImageMagick is a FOSS software suite for modifying images. This does NOT provide any of the utilities. It installs the C/C++ Libraries.")
    add_urls("https://download.imagemagick.org/ImageMagick/download/ImageMagick-$(version).tar.gz")
    add_versions("7.0.11-13", "6c162d7cbd7b80968a6d083d39eb18d9c9bbd49f500f7f49c9a5dcc0fc36a03b")
    add_deps("bzip2", "freetype", "fontconfig", "libxml2", "lzma", "pkg-config")
    add_configs("exr", {description = "Enable exr support.", default = false, type = "boolean"})
    add_configs("ffmpeg", {description = "Enable ffmpeg support.", default = false, type = "boolean"})
    add_configs("fftw", {description = "Enable fftw support.", default = false, type = "boolean"})
    add_configs("jasper", {description = "Enable jasper support.", default = false, type = "boolean"})
    add_configs("jpeg_turbo", {description = "Enable jpeg support through libjpeg-turbo.", default = false, type = "boolean"})
    add_configs("openjpeg", {description = "Enable jpeg support through openjpeg.", default = false, type = "boolean"})
    add_configs("png", {description = "Enable png support.", default = true, type = "boolean"})
    add_configs("tiff", {description = "Enable tiff support.", default = false, type = "boolean"})
    add_configs("webp", {description = "Enable webp support.", default = false, type = "boolean"})
    add_includedirs("include/ImageMagick-7")

    on_load(function(package)
        local configdeps = {exr        = "openexr",
                            ffmpeg     = "ffmpeg",
                            fftw       = "fftw",
                            jasper     = "jasper",
                            jpeg_turbo = "libjpeg-turbo",
                            openjpeg   = "openjpeg",
                            png        = "libpng",
                            tiff       = "libtiff",
                            webp       = "libwebp"}
        for name, dep in pairs(configdeps) do
            if package:config(name) then
                package:add("deps", dep)
                if name == "tiff" then
                    package:add("deps", "zlib")
                end
            end
        end
    end)

    on_install("bsd", "linux", "macosx", function(package)
        local configs = {"--with-utilities=no", "--with-x=no", "--without-djvu", "--without-jbig", "--disable-openmp"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no")) 
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes")) 
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("MagickWandGenesis", {includes = "MagickWand/MagickWand.h"}))
    end)
