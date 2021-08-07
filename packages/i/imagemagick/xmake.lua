package("imagemagick")

    set_homepage("https://imagemagick.org/script/index.php")
    set_description("ImageMagick is a FOSS software suite for modifying images. This does NOT provide any of the utilities. It installs the C/C++ Libraries.")
    set_license("Apache-2.0")

    add_urls("https://download.imagemagick.org/ImageMagick/download/releases/ImageMagick-$(version).tar.gz")
    add_versions("7.0.11-13", "6c162d7cbd7b80968a6d083d39eb18d9c9bbd49f500f7f49c9a5dcc0fc36a03b")
    add_versions("7.1.0-4", "94a7a52f633891cc29eefc49da95408ed68c64c3690402dc401cd0478d2bd91f")

    add_configs("bzlib", {description = "Enable bzip2 support.", default = false, type = "boolean"})
    add_configs("exr", {description = "Enable exr support.", default = false, type = "boolean"})
    add_configs("fftw", {description = "Enable fftw support.", default = false, type = "boolean"})
    add_configs("fontconfig", {description = "Enable fontconfig support.", default = false, type = "boolean"})
    add_configs("freetype", {description = "Enable freetype support.", default = false, type = "boolean"})
    add_configs("jpeg", {description = "Enable jpeg support through libjpeg.", default = true, type = "boolean"})
    add_configs("lzma", {description = "Enable LZMA support.", default = false, type = "boolean"})
    add_configs("openjpeg", {description = "Enable jpeg support through openjpeg.", default = false, type = "boolean"})
    add_configs("png", {description = "Enable png support.", default = true, type = "boolean"})
    add_configs("raw", {description = "Enable raw image support.", default = false, type = "boolean"})
    add_configs("tiff", {description = "Enable tiff support.", default = false, type = "boolean"})
    add_configs("threads", {description = "Enable threading support.", default = false})
    add_configs("xml", {description = "Enable XML support.", default = false, type = "boolean"})
    add_configs("webp", {description = "Enable webp support.", default = false, type = "boolean"})

    add_includedirs("include/ImageMagick-7/")
    add_links("MagickWand-7.Q16", "MagickCore-7.Q16", "Magick++-7.Q16")

    on_load(function(package)
        local configdeps = {bzlib      = "bzip2",
                            exr        = "openexr",
                            ffmpeg     = "ffmpeg",
                            fontconfig = "fontconfig",
                            freetype   = "freetype",
                            fftw       = "fftw",
                            jpeg       = "libjpeg",
                            lzma       = "lzma",
                            openjpeg   = "openjpeg",
                            png        = "libpng",
                            raw        = "libraw",
                            tiff       = "libtiff",
                            xml        = "libxml2",
                            webp       = "libwebp"}

        for name, dep in pairs(configdeps) do
            if package:config(name) then
                package:add("deps", dep)
                if name == "tiff" then
                    package:add("deps", "zlib")
                end
            end
        end

        if package:config("threads") and package:is_plat("linux") then
            package:add("syslinks", "pthread")
        end

        if package:is_plat("linux") then
            package:add("deps", "pkg-config")
        end

        if package:is_plat("bsd") then
            package:add("deps", "pkgconf")
            local pkgconf = package:find_tool("pkgconf")
            if pkgconf then
                package:addenv("PKG_CONFIG", pkgconf.program)
            end
        end
    end)

    on_install("linux", "macosx", "bsd", function(package)
        local configs = {"--without-utilities",
                         "--without-x",
                         "--without-djvu",
                         "--without-jbig",
                         "--disable-openmp",
                         "--without-perl",
                         "--without-lcms",
                         "--disable-hdri",
                         "--without-lqr"}
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                if enabled then
                    if name == "openjpeg" then
                        table.insert(configs, "--with-" .. "openjp2")
                    elseif name == "exr" then
                        table.insert(configs, "--with-" .. "openexr")
                    else
                        table.insert(configs, "--with-" .. name)
                    end
                else
                    if name == "openjpeg" then
                        table.insert(configs, "--without-" .. "openjp2")
                    elseif name == "exr" then
                        table.insert(configs, "--without-" .. "openexr")
                    else
                        table.insert(configs, "--without-" .. name)
                    end
                end
            end
        end
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no")) 
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes")) 
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end

        if not package:config("threads") then
            table.insert(configs, "--without-threads")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("MagickWandGenesis", {includes = "MagickWand/MagickWand.h"}))
    end)
