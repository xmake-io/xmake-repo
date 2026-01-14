package("cairo")
    set_homepage("https://cairographics.org/")
    set_description("Vector graphics library with cross-device output support.")
    set_license("MPL-1.1")

    add_urls("https://gitlab.freedesktop.org/cairo/cairo/-/archive/$(version)/cairo-$(version).tar.gz",
             "https://gitlab.freedesktop.org/cairo/cairo.git")

    add_versions("1.18.0", "39a78afdc33a435c0f2ab53a5ec2a693c3c9b6d2ec9783ceecb2b94d54d942b0")
    add_versions("1.17.8", "b4ed6d33037171d4c6594345b42d81796f335a6995fdf5638db0d306c17a0d3e")
    add_versions("1.17.6", "a2227afc15e616657341c42af9830c937c3a6bfa63661074eabef13600e8936f")

    add_patches("1.18.0", path.join(os.scriptdir(), "patches", "1.18.0", "alloca.patch"), "55f8577929537d43eed9f74241560821001b6c8613d6a7a21cff83f8431c6a70")
    if is_plat("mingw", "msys", "cygwin") then
        add_patches("1.18.0", "patches/1.18.0/mingw.patch", "b8d0c2a44b054e9fd1365f3db4490e6ebcb980cda6453c8d8202cc37a0ee4d19")
    end

    add_configs("freetype",   {description = "Enable freetype support.", default = true, type = "boolean"})
    add_configs("fontconfig", {description = "Enable fontconfig support.", default = true, type = "boolean"})
    add_configs("xlib",       {description = "Enable x11 surface backend.", default = is_plat("linux"), type = "boolean"})
    add_configs("glib",       {description = "Enable glib dependency.", default = false, type = "boolean"})
    add_configs("lzo",        {description = "Enable lzo dependency.", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("meson", "ninja")
    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end
    add_deps("libpng", "pixman", "zlib")

    add_includedirs("include", "include/cairo")

    if is_plat("linux", "macosx") then
        add_syslinks("pthread")
    end

    if is_plat("windows", "mingw") then
        add_syslinks("gdi32", "msimg32", "user32", "ole32", "windowscodecs")
    elseif is_plat("macosx") then
        add_frameworks("CoreGraphics", "CoreFoundation", "CoreText", "Foundation")
    end

    on_load(function (package)
        if package:is_plat("windows", "mingw") and not package:config("shared") then
            package:add("defines", "CAIRO_WIN32_STATIC_BUILD=1")
        end
        if package:config("freetype") then
            package:add("deps", "freetype")
        end
        if package:config("fontconfig") then
            if package:is_plat("windows", "mingw", "msys", "cygwin") then
                -- fontconfig symbols are absorbed into cairo-2.dll and re-exported by Meson.
                -- Linking both cairo and fontconfig downstream will cause symbol duplication.
                package:add("deps", "fontconfig", {configs = {shared = package:config("shared")}})
            else
                package:add("deps", "fontconfig")
            end
        end
        if package:config("xlib") then
            package:add("deps", "libx11", "libxrender", "libxext")
        end
        if package:config("glib") then
            package:add("deps", "glib")
        end
        if package:config("lzo") then
            package:add("deps", "lzo")
        end
    end)

    on_install("!wasm", function (package)
        io.replace("meson.build", "subdir('fuzzing')", "", {plain = true})
        io.replace("meson.build", "subdir('docs')", "", {plain = true})
        io.replace("meson.build", "'CoreFoundation'", "'CoreFoundation', 'Foundation'", {plain = true})
        -- fix for non-glibc system
        -- @see https://bugs.gentoo.org/903907
        if package:version() and package:version():lt("1.18.2") then
            io.replace("util/meson.build", "libmallocstats = library('malloc-stats', 'malloc-stats.c', dependencies : dl_dep)", "", {plain = true})
        end

        local configs = {
            "--wrap-mode=nopromote",
            "-Dtests=disabled",
            "-Dgtk_doc=false",
            "-Dgtk2-utils=disabled",
            "-Dpng=enabled",
            "-Dzlib=enabled",
        }
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Dfreetype=" .. (package:config("freetype") and "enabled" or "disabled"))
        table.insert(configs, "-Dfontconfig=" .. (package:config("fontconfig") and "enabled" or "disabled"))
        table.insert(configs, "-Dxlib=" .. (package:config("xlib") and "enabled" or "disabled"))
        table.insert(configs, "-Dglib=" .. (package:config("glib") and "enabled" or "disabled"))
        if package:version() and package:version():ge("1.18.4") then
            table.insert(configs, "-Dlzo=" .. (package:config("lzo") and "enabled" or "disabled"))
        end
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cairo_create", {includes = "cairo.h"}))
    end)
