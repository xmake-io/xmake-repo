package("cairo")

    set_homepage("https://cairographics.org/")
    set_description("Vector graphics library with cross-device output support.")

    add_urls("https://gitlab.freedesktop.org/cairo/cairo/-/archive/a04786b9330109ce54bf7f65c7068281419cec6a/cairo-a04786b9330109ce54bf7f65c7068281419cec6a.tar.gz")
    add_versions("2021.10.07", "8fc7e374a2de1d975171b58c7d43e4d430a28da082c0536ad6e2b178a9863d03")

    add_deps("meson", "ninja")
    add_deps("libpng", "pixman", "zlib", "freetype", "expat", "glib")
    if is_plat("windows") then
        add_deps("pkgconf")
    end

    add_patches("2021.10.07", path.join(os.scriptdir(), "patches", "2021.10.07", "macosx.patch"), "8f47e272eb9112e0592b2fcf816fe225c6540a9298dbddc38543ae2fc9fe4e6d")

    if is_plat("linux") or is_plat("macosx") then
        add_syslinks("pthread")
    end

    if is_plat("windows") then
        add_syslinks("gdi32", "msimg32", "user32")
    elseif is_plat("macosx") then
        add_frameworks("CoreGraphics", "CoreFoundation", "Foundation")
    end

    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "CAIRO_WIN32_STATIC_BUILD=1")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {
            "-Dtests=disabled",
            "-Dgtk_doc=false",
            "-Dfontconfig=disabled",
            "-Dgtk2-utils=disabled"}
        table.insert(configs, "-Ddebug=" .. (package:debug() and "true" or "false"))
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        io.replace("meson.build", "subdir('fuzzing')", "", {plain = true})
        io.replace("meson.build", "subdir('docs')", "", {plain = true})
        io.replace("meson.build", "fallback: ['fontconfig', 'fontconfig_dep'],", "", {plain = true})
        io.replace("meson.build", "'CoreFoundation'", "'CoreFoundation', 'Foundation'", {plain = true})
        io.replace("meson.build", "subdir('util')", "", {plain = true})
        io.replace("src/meson.build", ", subdir: 'cairo'", "", {plain = true})
        io.replace("util/cairo-gobject/meson.build", ", subdir: 'cairo'", "", {plain = true})
        io.replace("util/cairo-script/meson.build", ", subdir: 'cairo'", "", {plain = true})

        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cairo_create", {includes = "cairo.h"}))
    end)
