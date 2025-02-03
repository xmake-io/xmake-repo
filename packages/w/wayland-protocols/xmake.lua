package("wayland-protocols")
    set_homepage("https://wayland.freedesktop.org")
    set_description("Additional Wayland protocols")
    set_license("MIT")

    add_urls("https://gitlab.freedesktop.org/wayland/wayland-protocols/-/releases/$(version)/downloads/wayland-protocols-$(version).tar.xz")
    add_urls("https://wayland.freedesktop.org/releases/wayland-protocols-$(version).tar.xz")
    add_versions("1.24", "bff0d8cffeeceb35159d6f4aa6bab18c807b80642c9d50f66cba52ecf7338bc2")
    add_versions("1.25", "f1ff0f7199d0a0da337217dd8c99979967808dc37731a1e759e822b75b571460")
    add_versions("1.26", "c553384c1c68afd762fa537a2569cc9074fe7600da12d3472761e77a2ba56f13")
    add_versions("1.27", "9046f10a425d4e2a00965a03acfb6b3fb575a56503ac72c2b86821c69653375c")
    add_versions("1.28", "c7659fb6bf14905e68ef605f898de60d1c066bf66dbea92798573dddec1535b6")
    add_versions("1.29", "e25e9ab75ac736704ddefe92e8f9ac8730beab6f564db62f7ad695bba4ff9ed8")
    add_versions("1.30", "3c1498fb65fd2b80b0376d7e87cf215e6ae957b2ccdba5da45a448718831bc60")
    add_versions("1.31", "a07fa722ed87676ec020d867714bc9a2f24c464da73912f39706eeef5219e238")
    add_versions("1.32", "7459799d340c8296b695ef857c07ddef24c5a09b09ab6a74f7b92640d2b1ba11")
    add_versions("1.39", "e1dcdcbbf08e2e0a8a02ee5d9a0be3a6aafc39a4b51fa7e0d2f1a16411cb72fa")

    add_deps("meson", "ninja", "wayland", "pkg-config")

    if is_plat("linux") then
        add_extsources("apt::wayland-protocols", "pacman::wayland-protocols")
    end

    on_install("linux|native", function (package)
        local configs = {"-Dtests=false"}
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        local envs = {PKG_CONFIG_PATH = package:installdir("share/pkgconfig")}
        os.vrunv("pkg-config", {"--exists", "wayland-protocols"}, {envs = envs})
    end)
