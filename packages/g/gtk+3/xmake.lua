package("gtk+3")

    set_homepage("https://gtk.org/")
    set_description("Toolkit for creating graphical user interfaces")
    set_license("LGPL-2.0-or-later")

    add_urls("https://gitlab.gnome.org/GNOME/gtk/-/archive/3.24.43/gtk-$(version).tar.gz")
    add_versions("3.24.43", "ab197f76719fc875067671247533f8e5bd2bc090568ec17317de410d06397b7f")

    on_fetch("linux", function (package, opt)
        if opt.system and package.find_package then
            return package:find_package("pkgconfig::gtk+-3.0")
        end
    end)

    add_includedirs("include", "include/gtk-3.0")

    if is_plat("linux") then
        add_syslinks("pthread", "rt")
    end

    add_deps("meson", "ninja")
    add_deps("glib", "gdk-pixbuf", "pango", "libepoxy", "graphene", "libxkbcommon")
    add_deps("libx11", "libxfixes", "libxcursor", "libxi", "libxcomposite", "libxrandr", "libxdamage", "libxinerama", "at-spi2-core")
    add_links("gtk-3", "gdk-3", "gailutil-3", "X11", "X11-cxb", "pangocairo-1.0", "pango", "cairo")

    on_install("linux", "windows", "macosx", function (package)
        local configs = {"-Dintrospection=false", "-Ddemos=false", "-Dexamples=false", "-Dtests=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs, {packagedeps = {"libthai", "libdatrie", "gdk-pixbuf"}})
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                GtkApplication *app;
                app = gtk_application_new ("org.gtk.example", 0);
            }
        ]]}, {includes = "gtk/gtk.h"}))
    end)