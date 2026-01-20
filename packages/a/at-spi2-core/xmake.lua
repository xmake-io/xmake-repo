package("at-spi2-core")
    set_homepage("https://gitlab.gnome.org/GNOME/at-spi2-core")
    set_description("contains the DBus interface definitions for AT-SPI - the core of an accessibility stack for free software systems.")
    set_license("LGPL-2.1")

    add_urls("https://gitlab.gnome.org/GNOME/at-spi2-core.git")
    add_urls("https://gitlab.gnome.org/GNOME/at-spi2-core/-/archive/AT_SPI2_CORE_$(version)/at-spi2-core-AT_SPI2_CORE_$(version).tar.gz", {version = function (version)
        return version:gsub("%.", "_")
    end})
    add_versions("2.53.90", "6b0a7c15b5fceb69f501e8b6b8bebe9896c35b9edb1ee08fe0b202d488a71363")

    add_includedirs("include", "include/at-spi-2.0", "include/atk-1.0", "include/at-spi2-atk/2.0")

    add_links("atk-bridge-2.0", "atspi", "atk-1.0")

    add_deps("meson", "ninja", "pkg-config")
    add_deps("glib", "dbus", "libx11", "libxtst", "libxi", "libxml2")

    on_install("linux", function (package)
        local configs = {}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs, {packagedeps = {"glib", "libiconv", "libx11", "libxtst", "libxi", "libxext", "dbus"}})

        local atspi_pkgconfig_dir = package:installdir("lib/pkgconfig/atspi-2.pc")
        io.replace(atspi_pkgconfig_dir, [[-DG_LOG_DOMAIN="dbind"]], [[-DG_LOG_DOMAIN=\"dbind\"]])
    end)

    on_test(function (package)
        assert(package:has_cfuncs("atk_bridge_adaptor_init", {includes = "atk-bridge.h"}))
        assert(package:has_cfuncs("atk_object_initialize", {includes = "atk/atk.h"}))
    end)
