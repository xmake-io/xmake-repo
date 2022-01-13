package("libxmu")

    set_homepage("https://gitlab.freedesktop.org/xorg/lib/libxmu")
    set_description("X.Org: X miscellaneous utility routines library")

    add_urls("https://www.x.org/archive/individual/lib/libXmu-$(version).tar.gz")
    add_versions("1.1.3", "5bd9d4ed1ceaac9ea023d86bf1c1632cd3b172dce4a193a72a94e1d9df87a62e")

    if is_plat("linux") then
        add_extsources("apt::libxmu-dev", "pacman::libxmu")
    end

    add_deps("libxt", "libxext")

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("XmuNewArea", {includes = "X11/Xmu/Xmu.h"}))
    end)
