package("cairo")

    set_homepage("https://cairographics.org/")
    set_description("Vector graphics library with cross-device output support.")
    set_license("MPL-1.1")

    add_urls("https://gitlab.freedesktop.org/cairo/cairo/-/archive/$(version)/cairo-$(version).tar.gz")
    add_urls("https://gitlab.freedesktop.org/cairo/cairo.git")
    add_versions("1.17.6", "a2227afc15e616657341c42af9830c937c3a6bfa63661074eabef13600e8936f")
    add_versions("1.17.8", "b4ed6d33037171d4c6594345b42d81796f335a6995fdf5638db0d306c17a0d3e")
    add_versions("1.18.0", "39a78afdc33a435c0f2ab53a5ec2a693c3c9b6d2ec9783ceecb2b94d54d942b0")

    add_patches("1.18.0", path.join(os.scriptdir(), "patches", "1.18.0", "alloca.patch"), "55f8577929537d43eed9f74241560821001b6c8613d6a7a21cff83f8431c6a70")

    add_configs("freetype",   {description = "Enable freetype support.", default = true, type = "boolean"})
    add_configs("fontconfig", {description = "Enable fontconfig support.", default = true, type = "boolean"})
    add_configs("xlib",       {description = "Enable x11 surface backend.", default = is_plat("linux"), type = "boolean"})

    add_deps("meson", "ninja")
    add_deps("libpng", "pixman", "zlib", "glib")
    if is_plat("windows") then
        add_deps("pkgconf", "libintl")
    elseif is_plat("macosx") then
        add_deps("libiconv", {system = true})
    elseif is_plat("linux") then
        add_deps("libiconv")
    end

    add_includedirs("include", "include/cairo")

    if is_plat("linux", "macosx") then
        add_syslinks("pthread")
    end

    if is_plat("windows") then
        add_syslinks("gdi32", "msimg32", "user32", "ole32")
    elseif is_plat("macosx") then
        add_frameworks("CoreGraphics", "CoreFoundation", "CoreText", "Foundation")
    end

    on_load("windows|x64", "windows|x86", "macosx", "linux", function (package)
        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "CAIRO_WIN32_STATIC_BUILD=1")
        end
        if package:config("freetype") then
            package:add("deps", "freetype")
        end
        if package:config("fontconfig") then
            package:add("deps", "fontconfig")
        end
        if package:config("xlib") then
            package:add("deps", "libx11", "libxrender", "libxext")
        end
    end)

    on_install("windows|x64", "windows|x86", "macosx", "linux", function (package)
        import("package.tools.meson")

        local configs = {
            "--wrap-mode=nopromote",
            "-Dtests=disabled",
            "-Dgtk_doc=false",
            "-Dgtk2-utils=disabled",
            "-Dpng=enabled",
            "-Dzlib=enabled",
            "-Dglib=enabled"
        }
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Dfreetype=" .. (package:config("freetype") and "enabled" or "disabled"))
        table.insert(configs, "-Dfontconfig=" .. (package:config("fontconfig") and "enabled" or "disabled"))
        table.insert(configs, "-Dxlib=" .. (package:config("xlib") and "enabled" or "disabled"))
        io.replace("meson.build", "subdir('fuzzing')", "", {plain = true})
        io.replace("meson.build", "subdir('docs')", "", {plain = true})
        io.replace("meson.build", "'CoreFoundation'", "'CoreFoundation', 'Foundation'", {plain = true})
        local envs = meson.buildenvs(package, {packagedeps = {"libintl", "libiconv"}})
        if package:is_plat("windows") then
            envs.PATH = package:dep("pkgconf"):installdir("bin") .. path.envsep() .. envs.PATH
        end
        meson.install(package, configs, {envs = envs})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cairo_create", {includes = "cairo.h"}))
    end)
