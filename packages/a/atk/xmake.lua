package("atk")

    set_homepage("https://gitlab.gnome.org/GNOME/atk")
    set_description("ATK - The Accessibility Toolkit")
    set_license("LGPL-2.0")

    add_urls("https://download.gnome.org/sources/atk/$(version).tar.xz", {version = function (version)
        return format("%d.%d/atk-%s", version:major(), version:minor(), version)
    end})
    add_versions("2.36.0", "fb76247e369402be23f1f5c65d38a9639c1164d934e40f6a9cf3c9e96b652788")

    if is_plat("linux") then
        add_extsources("apt::libatk1.0-dev")
    end

    add_deps("meson", "ninja", "glib", "pkg-config")
    add_includedirs("include/atk-1.0")
    on_install("linux", function (package)
        local configs = {"-Dintrospection=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("atk_object_initialize", {includes = "atk/atk.h"}))
    end)
