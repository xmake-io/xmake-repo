package("libsm")

    set_homepage("https://gitlab.freedesktop.org/xorg/lib/libsm")
    set_description("X.Org: X Session Management Library")

    add_urls("https://www.x.org/archive/individual/lib/libSM-$(version).tar.gz")
    add_versions("1.2.3", "1e92408417cb6c6c477a8a6104291001a40b3bb56a4a60608fdd9cd2c5a0f320")

    if is_plat("linux") then
        add_extsources("apt::libsm-dev", "pacman::libsm")
    end

    add_deps("libice")

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SmcOpenConnection", {includes = "X11/SM/SMlib.h"}))
    end)
