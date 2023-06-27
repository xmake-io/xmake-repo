package("cairo")

    set_homepage("https://cairographics.org/")
    set_description("Vector graphics library with cross-device output support.")

    add_urls("https://gitlab.freedesktop.org/cairo/cairo/-/archive/$(version)/cairo-$(version).tar.gz")
    add_urls("https://gitlab.freedesktop.org/cairo/cairo.git")
    add_versions("1.17.6", "a2227afc15e616657341c42af9830c937c3a6bfa63661074eabef13600e8936f")
    add_versions("1.17.8", "b4ed6d33037171d4c6594345b42d81796f335a6995fdf5638db0d306c17a0d3e")

    add_deps("meson", "ninja")
    add_deps("libpng", "pixman", "zlib", "freetype", "glib")
    if is_plat("windows") then
        add_deps("pkgconf")
    end

    add_includedirs("include", "include/cairo")

    if is_plat("linux", "macosx") then
        add_syslinks("pthread")
        add_deps("fontconfig")
    end

    if is_plat("windows") then
        add_syslinks("gdi32", "msimg32", "user32", "ole32")
    elseif is_plat("macosx") then
        add_frameworks("CoreGraphics", "CoreFoundation", "CoreText", "Foundation")
    end

    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "CAIRO_WIN32_STATIC_BUILD=1")
        end
    end)

    on_install("windows|x64", "windows|x86", "macosx", "linux", function (package)
        import("package.tools.meson")

        local configs = {
            "--wrap-mode=nopromote",
            "-Dtests=disabled",
            "-Dgtk_doc=false",
            "-Dfreetype=enabled",
            "-Dgtk2-utils=disabled",
            "-Dpng=enabled",
            "-Dzlib=enabled",
            "-Dglib=enabled"
        }
        if package:is_plat("macosx") or package:is_plat("linux") then
            table.insert(configs, "-Dfontconfig=enabled")
        else
            table.insert(configs, "-Dfontconfig=disabled")
        end
        table.insert(configs, "-Ddebug=" .. (package:debug() and "true" or "false"))
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        io.replace("meson.build", "subdir('fuzzing')", "", {plain = true})
        io.replace("meson.build", "subdir('docs')", "", {plain = true})
        io.replace("meson.build", "subdir('util')", "", {plain = true})
        io.replace("meson.build", "'CoreFoundation'", "'CoreFoundation', 'Foundation'", {plain = true})
        local envs = meson.buildenvs(package)
        if package:is_plat("windows") then
            envs.PATH = package:dep("pkgconf"):installdir("bin") .. path.envsep() .. envs.PATH
        end
        meson.install(package, configs, {envs = envs})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cairo_create", {includes = "cairo.h"}))
    end)
