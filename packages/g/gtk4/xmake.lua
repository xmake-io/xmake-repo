package("gtk4")
    set_homepage("https://gtk.org/")
    set_description("Toolkit for creating graphical user interfaces")
    set_license("LGPL-2.0-or-later")

    add_urls("https://gitlab.gnome.org/GNOME/gtk.git")
    add_urls("https://download.gnome.org/sources/gtk/$(version).tar.xz", {version = function (version)
        return format("%d.%d/gtk-%s", version:major(), version:minor(), version)
    end})
    add_versions("4.13.3", "4f04a43e7c287360473f34fc27b629f64875795f3bc7ec2781df449c5e72f312")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    add_configs("x11", {description = "Enable the X11 gdk backend.", default = is_plat("linux"), type = "boolean"})
    add_configs("wayland", {description = "Enable the wayland gdk backend.", default = false, type = "boolean"})

    if is_plat("linux") then
        add_extsources("apt::libgtk-4-dev")
    end

    add_includedirs("include/gtk-4.0")

    -- https://github.com/mesonbuild/meson/issues/6710
    add_deps("meson >=1.8.3", "ninja")
    add_deps("glib", "pango", "gdk-pixbuf", "graphene", "fribidi")
    add_deps("harfbuzz", "cairo", {configs = {glib = true}})
    if is_plat("linux") then
        add_deps("libdrm")
        add_deps("libepoxy", {configs = {glx = true, x11 = true, egl = true}})
    else
        add_deps("libepoxy")
    end

    on_fetch(function (package, opt)
        if opt.system then
            return package:find_package("pkgconfig::gtk4")
        end
    end)

    on_load(function (package)
        if package:config("x11") then
            package:add("deps", "libx11", "libxrandr", "libxi", "libxcursor", "libxext", "libxdamage", "libxfixes", "libxinerama")
        end
        if package:config("wayland") then
            package:add("deps", "wayland", "libxkbcommon")
        end
        package:addenv("PATH", "bin")
    end)

    on_install("windows|!arm*", "macosx", "linux", "mingw", function (package)
        import("package.tools.meson")

        os.rm("subprojects")

        io.replace("meson.build", "xext_dep,", "[x11_dep, xext_dep],", {plain = true})
        io.replace("meson.build", "xi_dep)", "[x11_dep, xext_dep, xi_dep])", {plain = true})

        local configs = {
            "-Dintrospection=disabled",
            "-Dbuild-tests=false",
            "-Dbuild-testsuite=false",
            "-Dbuild-examples=false",
            "-Dbuild-demos=false",
            "-Dmedia-gstreamer=disabled",
            "-Dmedia-ffmpeg=disabled",
        }
        table.insert(configs, "-Dx11-backend=" .. (package:config("x11") and "true" or "false"))
        table.insert(configs, "-Dwayland-backend=" .. (package:config("wayland") and "true" or "false"))

        local shflags
        local envs = meson.buildenvs(package)
        if package:is_plat("linux") then
            local pc_path = path.splitenv(envs.PKG_CONFIG_PATH)
            table.insert(pc_path, path.join(package:dep("shared-mime-info"):installdir(), "share/pkgconfig"))
            envs.PKG_CONFIG_PATH = path.joinenv(pc_path)
        elseif package:is_plat("mingw") then
            -- gtk (c code) will call gcc to link, but cairo (c++ code) require g++
            shflags = "-lstdc++"
        end
        meson.install(package, configs, {envs = envs, shflags = shflags})
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
