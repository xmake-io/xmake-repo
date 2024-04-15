package("libvips")
    set_homepage("https://libvips.github.io/libvips/")
    set_description("A fast image processing library with low memory needs.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/libvips/libvips/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libvips/libvips.git")

    -- add_versions("v8.15.2", "8c3ece7be367636fd676573a8ff22170c07e95e81fd94f2d1eb9966800522e1f")
    add_versions("v8.15.1", "5701445a076465a3402a135d13c0660d909beb8efc4f00fbbe82392e243497f2")

    add_configs("c++", { description = "Build C++ API", default = true, type = "boolean" })
    add_configs("deprecated", { description = "Build deprecated components", default = false, type = "boolean" })

    add_configs("nsgif", { description = "Build with nsgif", default = false, type = "boolean" })
    add_configs("ppm", { description = "Build with ppm", default = false, type = "boolean" })
    add_configs("analyze", { description = "Build with analyze", default = false, type = "boolean" })
    add_configs("radiance", { description = "Build with radiance", default = false, type = "boolean" })

    add_deps("meson", "ninja")
    add_deps("glib", "expat")

    if is_plat("linux") then
        add_extsources("apt::libvips", "pacman::libvips")
    elseif is_plat("macosx") then
        add_extsources("brew::vips")
    elseif is_plat("windows") then
        add_deps("pkgconf")
    end

    on_install("windows", "macosx", "linux", "cross", function (package)
        io.replace("meson.build", "subdir('tools')", "", {plain = true})
        io.replace("meson.build", "subdir('test')", "", {plain = true})
        io.replace("meson.build", "subdir('fuzz')", "", {plain = true})

        local configs = {"-Dexamples=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        for name, enabled in table.orderpairs(package:configs()) do
            if name == "c++" then
                name = "cplusplus"
            end
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-D" .. name .. "=" .. (enabled and "true" or "false"))
            end
        end
        import("package.tools.meson").install(package, configs, {packagedeps = {"libintl", "libiconv"}})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vips_image_new_from_file", {includes = "vips/vips.h"}))
    end)
