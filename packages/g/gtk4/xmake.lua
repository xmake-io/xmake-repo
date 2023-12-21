package("gtk4")

    set_homepage("https://gtk.org/")
    set_description("Toolkit for creating graphical user interfaces")
    set_license("LGPL-2.0-or-later")

    add_urls("https://download.gnome.org/sources/gtk/$(version).tar.xz", {version = function (version)
        return format("%d.%d/gtk-%s", version:major(), version:minor(), version)
    end})
    add_versions("4.13.3", "4f04a43e7c287360473f34fc27b629f64875795f3bc7ec2781df449c5e72f312")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    add_configs("x11", {description = "Enable the X11 gdk backend.", default = is_plat("linux"), type = "boolean"})
    add_configs("wayland", {description = "Enable the wayland gdk backend.", default = false, type = "boolean"})

    on_fetch("windows", "macosx", "linux", function (package, opt)
        if opt.system then
            return package:find_package("pkgconfig::gtk4")
        end
    end)

    if is_plat("linux") then
        add_extsources("apt::libgtk-4-dev")
    end

    add_deps("meson", "ninja")
    add_deps("glib", "pango", "cairo", "gdk-pixbuf", "libepoxy", "graphene", "fribidi", "pcre2")
    add_deps("harfbuzz", {configs = {glib = true}})
    if is_plat("linux") then
        add_deps("libdrm")
        add_deps("libiconv")
    elseif is_plat("macosx") then
        add_deps("libiconv", {system = true})
        add_deps("libintl")
    elseif is_plat("windows") then
        add_deps("libintl")
    end
    add_includedirs("include/gtk-4.0")

    on_load("windows|x64", "windows|x86", "macosx", "linux", function (package)
        if package:config("x11") then
            package:add("deps", "libx11", "libxrandr", "libxi", "libxcursor", "libxext", "libxdamage", "libxfixes", "libxinerama")
        end
        if package:config("wayland") then
            package:add("deps", "wayland", "libxkbcommon")
        end
    end)

    on_install("windows|x64", "windows|x86", "macosx", "linux", function (package)
        local mesondir = package:dep("meson"):installdir()
        local gnomemod = path.join(mesondir, "mesonbuild", "modules", "gnome.py")
        if package:is_plat("windows") then
            -- workaround https://github.com/mesonbuild/meson/issues/6710
            io.replace(gnomemod, "absolute_paths=True,", "absolute_paths=False,#x", {plain = true})
        end
        io.replace("meson.build", "xext_dep,", "[x11_dep, xext_dep],", {plain = true})
        io.replace("meson.build", "xi_dep)", "[x11_dep, xext_dep, xi_dep])", {plain = true})
        local configs = {"-Dintrospection=disabled",
                         "-Dbuild-tests=false",
                         "-Dbuild-testsuite=false",
                         "-Dbuild-examples=false",
                         "-Dbuild-demos=false",
                         "-Dmedia-gstreamer=disabled",
                         "-Dmedia-ffmpeg=disabled"}
        table.insert(configs, "-Dx11-backend=" .. (package:config("x11") and "true" or "false"))
        table.insert(configs, "-Dwayland-backend=" .. (package:config("wayland") and "true" or "false"))
        import("package.tools.meson").install(package, configs, {packagedeps = {"libintl", "libiconv", "pcre2"}})
        if package:is_plat("windows") then
            io.replace(gnomemod, "absolute_paths=False,#x", "absolute_paths=True,", {plain = true})
        end
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            int test(int argc, char *argv[]) {
                GtkApplication *app =
                    gtk_application_new("xmake.app", G_APPLICATION_DEFAULT_FLAGS);
                return g_application_run(G_APPLICATION(app), argc, argv);
            }
        ]]}, {includes = "gtk/gtk.h"}))
    end)
