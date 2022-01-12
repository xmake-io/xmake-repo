package("libice")

    set_homepage("https://gitlab.freedesktop.org/xorg/lib/libice")
    set_description("X.Org: Inter-Client Exchange Library")

    add_urls("https://www.x.org/archive/individual/lib/libICE-$(version).tar.gz")
    add_versions("1.0.10", "1116bc64c772fd127a0d0c0ffa2833479905e3d3d8197740b3abd5f292f22d2d")

    if is_plat("linux") then
        add_extsources("apt::libice-dev", "pacman::libice")
    end

    add_deps("xtrans")

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("IceOpenConnection", {includes = "X11/ICE/ICElib.h"}))
    end)
