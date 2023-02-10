package("pixman")

    set_homepage("https://cairographics.org/")
    set_description("Low-level library for pixel manipulation.")

    add_urls("https://cairographics.org/releases/pixman-$(version).tar.gz")
    add_urls("https://gitlab.freedesktop.org/pixman/pixman.git")
    add_versions("0.40.0", "6d200dec3740d9ec4ec8d1180e25779c00bc749f94278c8b9021f5534db223fc")
    add_versions("0.42.2", "ea1480efada2fd948bc75366f7c349e1c96d3297d09a3fe62626e38e234a625e")

    add_deps("meson", "ninja")

    add_includedirs("include", "include/pixman-1")

    on_install("macosx", "linux", "windows|x64", "windows|x86", function (package)
        local configs = {
            "-Dopenmp=disabled",
            "-Dlibpng=disabled",
            "-Dgtk=disabled"
        }
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        io.replace("meson.build", "subdir('test')", "", {plain = true})
        io.replace("meson.build", "subdir('demos')", "", {plain = true})
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pixman_image_create_solid_fill", {includes = "pixman.h"}))
    end)
