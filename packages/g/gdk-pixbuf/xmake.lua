package("gdk-pixbuf")

    set_homepage("https://gitlab.gnome.org/GNOME/gdk-pixbuf")
    set_description("GdkPixbuf is a library that loads image data in various formats and stores it as linear buffers in memory. The buffers can then be scaled, composited, modified, saved, or rendered.")
    set_license("LGPL-2.0")

    add_urls("https://github.com/GNOME/gdk-pixbuf/archive/refs/tags/$(version).tar.gz",
             "https://gitlab.gnome.org/GNOME/gdk-pixbuf/-/archive/$(version)/gdk-pixbuf-$(version).tar.gz",
             "https://gitlab.gnome.org/GNOME/gdk-pixbuf.git")

    add_versions("2.42.6", "c4f3a84a04bc7c5f4fbd97dce7976ab648c60628f72ad4c7b79edce2bbdb494d")
    add_includedirs("include", "include/gdk-pixbuf-2.0")

    add_deps("meson", "ninja")
    add_deps("libpng", "libjpeg")
    if is_plat("macosx") then
        add_frameworks("Foundation", "CoreFoundation", "AppKit")
        add_extsources("brew::gdk-pixbuf")
        add_syslinks("resolv")
        add_patches("2.42.6", path.join(os.scriptdir(), "patches", "2.42.6", "macosx.patch"), "ad2705a5a9aa4b90fb4588bb567e95f5d82fccb6a5d463cd07462180e2e418eb")
    elseif is_plat("linux") then
        add_extsources("pacman::gdk-pixbuf2")
    end

    on_load(function (package)
        if package:config("shared") then
            -- fix gobject conflict error: assertion failed: (type == G_TYPE_CHAR)
            package:add("deps", "glib", {configs = {shared = true}})
        else
            package:add("deps", "glib")
        end
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"-Dman=false",
                         "-Dgtk_doc=false",
                         "-Dpng=true",
                         "-Dtiff=true",
                         "-Dnative_windows_loaders=false",
                         "-Dgio_sniffing=false",
                         "-Drelocatable=true",
                         "-Djpeg=true",
                         "-Dinstalled_tests=false"}
        table.insert(configs, "-Ddebug=" .. (package:debug() and "true" or "false"))
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        io.gsub("meson.build", "subdir%('tests'%)", "")
        io.gsub("meson.build", "subdir%('fuzzing'%)", "")
        io.gsub("meson.build", "subdir%('docs'%)", "")
        import("package.tools.meson").install(package, configs, {packagedeps = {"libpng", "libjpeg", "glib"}})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gdk_pixbuf_get_type", {includes = "gdk-pixbuf/gdk-pixbuf.h"}))
    end)
