package("pixman")

    set_homepage("https://cairographics.org/")
    set_description("Low-level library for pixel manipulation.")

    add_urls("https://cairographics.org/releases/pixman-$(version).tar.gz")
    add_urls("https://gitlab.freedesktop.org/pixman/pixman.git")
    add_versions("0.40.0", "6d200dec3740d9ec4ec8d1180e25779c00bc749f94278c8b9021f5534db223fc")

    add_deps("meson", "ninja")

    add_includedirs("include", "include/pixman-1")

    on_install("macosx", "linux", "windows", function (package)
        local configs = {
            "-Dopenmp=disabled",
            "-Dlibpng=disabled",
            "-Dgtk=disabled"
        }
        table.insert(configs, "-Ddebug=" .. (package:debug() and "true" or "false"))
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        io.replace("meson.build", "subdir('test')", "", {plain = true})
        io.replace("meson.build", "subdir('demos')", "", {plain = true})
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pixman_image_create_solid_fill", {includes = "pixman.h"}))
    end)
