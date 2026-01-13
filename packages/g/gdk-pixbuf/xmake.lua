package("gdk-pixbuf")
    set_homepage("https://docs.gtk.org/gdk-pixbuf/")
    set_description("GdkPixbuf is a library that loads image data in various formats and stores it as linear buffers in memory. The buffers can then be scaled, composited, modified, saved, or rendered.")
    set_license("LGPL-2.1")

    add_urls("https://download.gnome.org/sources/gdk-pixbuf/$(version).tar.xz", {alias = "home", version = function (version)
        return format("%d.%d/gdk-pixbuf-%s", version:major(), version:minor(), version)
    end, excludes = "*/tests/*"})
    add_urls("https://gitlab.gnome.org/GNOME/gdk-pixbuf/-/archive/$(version)/gdk-pixbuf-$(version).tar.gz",
             "https://gitlab.gnome.org/GNOME/gdk-pixbuf.git")

    add_versions("home:2.44.2", "ea4ed9930b10db0655fb24f7c35b3375a65c58afbc9d3eb7417a0fd112bb6b08")
    add_versions("home:2.42.10", "ee9b6c75d13ba096907a2e3c6b27b61bcd17f5c7ebeab5a5b439d2f2e39fe44b")
    add_versions("home:2.42.6", "c4a6b75b7ed8f58ca48da830b9fa00ed96d668d3ab4b1f723dcf902f78bde77f")

    add_patches("2.44.2", "patches/2.44.2/docs-option.patch", "f6318b332941798d637e645afeb1750366af6ba863b9ca57a3c8b1be1b10478e")
    add_patches("2.42.6", "patches/2.42.6/macosx.patch", "ad2705a5a9aa4b90fb4588bb567e95f5d82fccb6a5d463cd07462180e2e418eb")

    if is_plat("linux") then
        add_configs("gio_sniffing", {description = "Perform file type detection using GIO", default = true, type = "boolean"})
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::gdk-pixbuf2")
    elseif is_plat("linux") then
        add_extsources("pacman::gdk-pixbuf2", "apt::libgdk-pixbuf-2.0-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::gdk-pixbuf")
    end

    add_includedirs("include", "include/gdk-pixbuf-2.0")

    if is_plat("windows") then
        add_syslinks("iphlpapi", "dnsapi")
    elseif is_plat("macosx") then
        add_frameworks("Foundation", "CoreFoundation", "AppKit")
        add_syslinks("resolv")
    end

    add_deps("meson", "ninja")
    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end

    add_deps("libpng", "libjpeg-turbo", "glib")

    on_load(function (package)
        if package:config("shared") then
            package:add("deps", "libtiff", {configs = {shared = true}})
        else
            package:add("deps", "libtiff")
        end
        if package:config("gio_sniffing") then
            package:add("deps", "shared-mime-info")
        end
        package:addenv("PATH", "bin")
    end)

    on_install("windows", "macosx", "linux", "mingw", function (package)
        import("package.tools.meson")

        io.gsub("meson.build", "subdir%('tests'%)", "")
        io.gsub("meson.build", "subdir%('fuzzing'%)", "")
        io.gsub("meson.build", "subdir%('docs'%)", "")

        if not package:is_plat("linux") then
            io.replace("meson.build", "cc.find_library('intl', required: false)", "dependency('libintl')", {plain = true})
        end

        local configs = {
            "-Dman=false",
            "-Dgtk_doc=false",
            "-Dpng=enabled",
            "-Dtiff=enabled",
            "-Djpeg=enabled",
            "-Dnative_windows_loaders=false",
            "-Dbuiltin_loaders=all",
            "-Drelocatable=true",
            "-Dintrospection=disabled",
            "-Dtests=false",
            "-Dinstalled_tests=false",
        }
        local version = package:version()
        if version and version:gt("2.42.12") then
            table.insert(configs, "-Ddocumentation=false")
            table.insert(configs, "-Dglycin=disabled")
        else
            table.insert(configs, "-Ddocs=false")
        end

        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))

        local opt = {}
        if package:config("gio_sniffing") then
            table.insert(configs, "-Dgio_sniffing=true")
            local envs = meson.buildenvs(package)
            local pc_path = path.splitenv(envs.PKG_CONFIG_PATH)
            table.insert(pc_path, path.join(package:dep("shared-mime-info"):installdir(), "share/pkgconfig"))

            envs.PKG_CONFIG_PATH = path.joinenv(pc_path)
            opt.envs = envs
        else
            table.insert(configs, "-Dgio_sniffing=false")
        end
        meson.install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gdk_pixbuf_get_type", {includes = "gdk-pixbuf/gdk-pixbuf.h"}))
    end)
