package("libvips")
    set_homepage("https://libvips.github.io/libvips/")
    set_description("A fast image processing library with low memory needs.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/libvips/libvips/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libvips/libvips.git")

    add_versions("v8.15.4", "16afc1bf2218a98c1dc35ec4d94ef61d66c293eeb2b399fd40282dfb2211ea95")
    add_versions("v8.15.3", "c23a820443241c35e62f1f1f0a1f6c199b37e07d98e3268a7fa9db43309fd67d")
    add_versions("v8.15.2", "8c3ece7be367636fd676573a8ff22170c07e95e81fd94f2d1eb9966800522e1f")
    add_versions("v8.15.1", "5701445a076465a3402a135d13c0660d909beb8efc4f00fbbe82392e243497f2")

    add_patches("8.15.3", "patches/8.15.3/msvc-ssize_t.patch", "1995af657dfd2f4e4f8edec685f67bd473537ff33c42d8329a0df0e0477408b9")

    add_configs("c++", { description = "Build C++ API", default = true, type = "boolean" })
    add_configs("deprecated", { description = "Build deprecated components", default = false, type = "boolean" })
    add_configs("dynamic_modules", { description = "Build dynamic modules", default = false, type = "boolean" })
    add_configs("introspection", { description = "Build GObject introspection data", default = false, type = "boolean" })
    add_configs("vapi", { description = "Build VAPI", default = false, type = "boolean" })

    add_configs("nsgif", { description = "Build with nsgif", default = false, type = "boolean" })
    add_configs("ppm", { description = "Build with ppm", default = false, type = "boolean" })
    add_configs("analyze", { description = "Build with analyze", default = false, type = "boolean" })
    add_configs("radiance", { description = "Build with radiance", default = false, type = "boolean" })

    local deps = {
        "cfitsio",
        "fftw",
        "fontconfig",
        "libarchive",
        "libheif",
        "libimagequant",
        "libjpeg",
        "libjxl",
        "lcms",
        "imagemagick",
        "matio",
        "openexr",
        "openjpeg",
        "poppler",
        "libpng",
        "libspng",
        "libtiff",
        "libwebp",
        "zlib",
        "cgif",
        "nifti",
        "highway",
    }

    local unsupported_deps = {
        "exif",
        "openslide",
        "orc",
        "pangocairo",
        "pdfium",
        "quantizr",
        "rsvg",
    }

    for _, dep in ipairs(deps) do
        add_configs(dep, { description = "Build with " .. dep, default = false, type = "boolean"})
    end

    for _, dep in ipairs(unsupported_deps) do
        add_configs(dep, { description = "Build with " .. dep, default = false, type = "boolean", readonly = true})
    end

    add_deps("meson", "ninja")
    add_deps("glib", "expat")
    if is_plat("windows") then
        add_deps("pkgconf")
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::libvips")
    elseif is_plat("linux") then
        add_extsources("apt::libvips", "pacman::libvips")
    elseif is_plat("macosx") then
        add_extsources("brew::vips")
    end

    on_load(function (package)
        for _, dep in ipairs(deps) do
            if package:config(dep) then
                package:add("deps", dep)
            end
        end
    end)

    on_install("windows", "macosx", "linux", "cross", function (package)
        io.replace("meson.build", "subdir('tools')", "", {plain = true})
        io.replace("meson.build", "subdir('test')", "", {plain = true})
        io.replace("meson.build", "subdir('fuzz')", "", {plain = true})

        local configs = {"-Dexamples=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))

        local configs_map = {
            ["c++"] = "cplusplus",
            ["dynamic_modules"] = "modules",
            ["libarchive"] = "archive",
            ["libheif"] = "heif",
            ["libimagequant"] = "imagequant",
            ["libjpeg"] = "jpeg",
            ["libjxl"] = "jpeg-xl",
            ["imagemagick"] = "magick",
            ["libpng"] = "png",
            ["libspng"] = "spng",
            ["libtiff"] = "tiff",
            ["libwebp"] = "webp",
        }

        table.join2(deps, unsupported_deps)
        -- workaround meson option type
        table.insert(deps, "dynamic_modules")
        table.insert(deps, "introspection")
        for name, enabled in table.orderpairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                local enabled_string
                if table.contains(deps, name) then
                    enabled_string = (enabled and "enabled" or "disabled")
                else
                    enabled_string = (enabled and "true" or "false")
                end

                if configs_map[name] then
                    name = configs_map[name]
                end
                table.insert(configs, "-D" .. name .. "=" .. enabled_string)
            end
        end

        import("package.tools.meson").install(package, configs, {
            packagedeps = {"libintl", "libiconv"},
            prefix = path.unix(package:installdir()) -- after xmake v2.9.1
        })
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vips_image_new_from_file", {includes = "vips/vips.h"}))
    end)
