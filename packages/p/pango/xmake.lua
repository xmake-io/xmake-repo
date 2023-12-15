package("pango")

    set_homepage("https://www.pango.org/")
    set_description("Framework for layout and rendering of i18n text")
    set_license("LGPL-2.0")

    add_urls("https://gitlab.gnome.org/GNOME/pango/-/archive/$(version)/pango-$(version).tar.gz")
    add_urls("https://gitlab.gnome.org/GNOME/pango.git")
    add_versions("1.51.1", "ea92cd570cdba62ca52cc0a7c9ea3cd311b6da3f0328a5aa8a4a81b0a74944a5")
    add_versions("1.50.3", "4a8b0cf33d5f9ecaa9cd99dd72703d5c4c53bc58df64dd9538493bb4356ab691")

    add_deps("meson", "ninja")
    add_deps("fontconfig", "freetype", "fribidi", "cairo", "glib", "pcre2")
    add_deps("harfbuzz", {configs = {glib = true}})
    if is_plat("windows") then
        add_deps("libintl")
    elseif is_plat("macosx") then
        add_deps("libintl")
        add_deps("libiconv", {system = true})
        add_extsources("brew::pango")
        add_frameworks("CoreFoundation")
    elseif is_plat("linux") then
        add_deps("libiconv")
        add_deps("xorgproto")
        add_extsources("apt::libpango-1.0-0", "pacman::pango")
    end
    add_includedirs("include", "include/pango-1.0")

    on_install("windows|x64", "windows|x86", "macosx", "linux", function (package)
        import("package.tools.meson")
        local configs = {"-Dintrospection=disabled", "-Dgtk_doc=false", "-Dfontconfig=enabled"}

        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        io.gsub("meson.build", "subdir%('tests'%)", "")
        io.gsub("meson.build", "subdir%('fuzzing'%)", "")
        io.gsub("meson.build", "subdir%('docs'%)", "")
        io.gsub("meson.build", "subdir%('examples'%)", "")
        io.gsub("meson.build", "subdir%('utils'%)", "")
        io.gsub("meson.build", "subdir%('tools'%)", "")

        io.replace("meson.build", "[ 'CoreFoundation', 'ApplicationServices' ]", "[ 'CoreFoundation', 'ApplicationServices', 'Foundation' ]", {plain = true})
        io.replace("meson.build", "dependency('gi-docgen'", "dependency(''", {plain = true})
        io.replace("meson.build", "fallback: ['gi-docgen', 'dummy_dep']", "fallback: ['dummy_dep']", {plain = true})

        -- fix unexpected -Werror=unused-but-set-variable errors, see https://gitlab.gnome.org/GNOME/pango/-/issues/693
        io.replace("meson.build", "'-Werror=unused-but-set-variable',", "", {plain = true})
        -- fix unexpected -Werror=array-bounds errors, see https://gitlab.gnome.org/GNOME/pango/-/issues/740
        io.replace("meson.build", "'-Werror=array-bounds',", "", {plain = true})

        local envs = meson.buildenvs(package, {packagedeps = {"fontconfig", "freetype", "harfbuzz", "fribidi", "cairo", "glib", "pcre2", "libintl", "libiconv"}})
        -- workaround for https://github.com/xmake-io/xmake/issues/4412
        envs.LDFLAGS = string.gsub(envs.LDFLAGS, "%-libpath:", "/libpath:")
        meson.install(package, configs, {envs = envs})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pango_layout_set_text", {includes = "pango/pangocairo.h"}))
    end)
