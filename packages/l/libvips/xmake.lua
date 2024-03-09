package("libvips")
    set_homepage("https://libvips.github.io/libvips/")
    set_description("A fast image processing library with low memory needs.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/libvips/libvips/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libvips/libvips.git")

    add_versions("v8.15.1", "5701445a076465a3402a135d13c0660d909beb8efc4f00fbbe82392e243497f2")

    add_configs("c++", { description = "Build C++ API", default = true, type = "boolean" })

    add_deps("meson", "ninja")
    add_deps("glib", "expat")

    on_install("windows", "macosx", "linux", "cross", function (package)
        io.replace("meson.build", "subdir('tools')", "", {plain = true})
        io.replace("meson.build", "subdir('test')", "", {plain = true})
        io.replace("meson.build", "subdir('fuzz')", "", {plain = true})

        local configs = {"-Dexamples=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Dcplusplus=" .. (package:config("c++") and "true" or "false"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vips_image_new_from_file", {includes = "vips/vips.h"}))
    end)
