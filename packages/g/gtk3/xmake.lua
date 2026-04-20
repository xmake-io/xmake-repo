package("gtk3")
    set_homepage("https://gtk.org/")
    set_description("Toolkit for creating graphical user interfaces")
    set_license("LGPL-2.0-or-later")

    add_urls("https://gitlab.gnome.org/GNOME/gtk/-/archive/$(version)/gtk-$(version).tar.gz")

    add_versions("3.24.51", "f3c87a20b3380b69efa720f412a0fea6ab6edce021f8ffaf5c4531fe1321b24f")
    add_versions("3.24.43", "ab197f76719fc875067671247533f8e5bd2bc090568ec17317de410d06397b7f")

    on_fetch("linux", function (package, opt)
        if opt.system and package.find_package then
            return package:find_package("pkgconfig::gtk+-3.0")
        end
    end)

    if is_plat("linux") then
        add_syslinks("rt")
        add_syslinks("pthread")
    end

    add_includedirs("include", "include/gtk-3.0")

    on_load("linux", function (package)
        if package:config("shared") then
            package:add("deps", "gdk-pixbuf", {configs = {shared = true}})
        else
            package:add("deps", "gdk-pixbuf")
        end
    end)

    add_deps("meson", "ninja")
    add_deps("cairo", {configs = {glib = true, xlib = true}})
    add_deps("glib", "pango", "graphene", "libxkbcommon", "libxext")
    add_deps("libepoxy", {configs = {egl = true, glx = true, x11 = true}})
    add_deps("libx11", "libxfixes", "libxcursor", "libxi", "libxcomposite", "libxrandr", "libxdamage", "libxinerama", "libiconv", "at-spi2-core")
    add_links("gtk-3", "gdk-3", "gailutil-3", "X11", "X11-cxb", "pangocairo-1.0", "pango", "rt")

    on_install("linux", function (package)
        local configs = {"-Dintrospection=false", "-Ddemos=false", "-Dexamples=false", "-Dtests=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        io.replace("gdk/x11/gdkglcontext-x11.c", [[cairo/cairo-xlib.h]], [[cairo-xlib.h]], {plain = true})
        import("package.tools.meson")
        local opt = {packagedeps = {"libiconv",
                                    "libx11",
                                    "libxext",
                                    "libxi",
                                    "pango",
                                    "at-spi2-core",
                                    "libthai",
                                    "libdatrie",
                                    "gdk-pixbuf"}}
        -- gdk-pixbuf-2.0.pc has Requires.private: shared-mime-info when gio_sniffing=true.
        -- shared-mime-info is a binary package so it's excluded from librarydeps and its
        -- share/pkgconfig is not in PKG_CONFIG_PATH, causing `pkg-config --static gdk-pixbuf-2.0`
        -- to fail. Add it manually so meson can find gdk-pixbuf-2.0.
        local smi = package:dep("shared-mime-info")
        if smi then
            local envs = meson.buildenvs(package, opt)
            local pc_path = path.splitenv(envs.PKG_CONFIG_PATH or "")
            local smi_pc = path.join(smi:installdir(), "share", "pkgconfig")
            if os.isdir(smi_pc) then
                table.insert(pc_path, smi_pc)
            end
            envs.PKG_CONFIG_PATH = path.joinenv(pc_path)
            opt.envs = envs
        end
        meson.install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gtk_application_new", {includes = "gtk/gtk.h"}))
    end)
