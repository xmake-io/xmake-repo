package("atk")
    set_homepage("https://gitlab.gnome.org/GNOME/atk")
    set_description("ATK - The Accessibility Toolkit")
    set_license("LGPL-2.0")

    add_urls("https://gitlab.gnome.org/Archive/atk/-/archive/$(version)/atk-$(version).tar.bz2",
             "https://gitlab.gnome.org/Archive/atk.git")

    add_versions("2.38.0", "469313d28bd22bcbf7b7ea300dddb9b6c13854455d297f4d51a944e378b0a9d7")

    add_configs("introspection", {description = "Whether to build introspection files", default = false, type = "boolean"})

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::atk")
    elseif is_plat("linux") then
        add_extsources("pacman::atk", "apt::libatk1.0-dev")
    elseif is_plat("macosx")then
        add_extsources("brew::atk")
    end

    add_includedirs("include/atk-1.0")

    add_deps("meson", "ninja", "glib")
    if is_plat("windows") then
        add_deps("pkgconf")
    end

    on_install("windows", "macosx", "linux", "cross", function (package)
        local configs = {}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Dintrospection=" .. (package:config("introspection") and "true" or "false"))
        import("package.tools.meson").install(package, configs, {packagedeps = {"libintl", "libiconv"}})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("atk_object_initialize", {includes = "atk/atk.h"}))
    end)
