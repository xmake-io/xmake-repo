package("wayland-protocols")
    set_homepage("https://wayland.freedesktop.org")
    set_description("Additional Wayland protocols")
    set_license("MIT")

    set_urls("https://wayland.freedesktop.org/releases/wayland-protocols-$(version).tar.xz")
    add_versions("1.24", "bff0d8cffeeceb35159d6f4aa6bab18c807b80642c9d50f66cba52ecf7338bc2")

    add_deps("meson", "ninja", "wayland", "pkg-config")

    if is_plat("linux") then 
        add_extsources("pacman::wayland-protocols")
    end

    on_install("linux", function (package)
        local configs = {}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        local envs = {PKG_CONFIG_PATH = package:installdir("share/pkgconfig")}
        os.vrunv("pkg-config", {"--exists", "wayland-protocols"}, {envs = envs})
    end)
