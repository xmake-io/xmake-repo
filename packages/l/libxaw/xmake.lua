package("libxaw")

    set_homepage("https://gitlab.freedesktop.org/xorg/lib/libxaw")
    set_description("X.Org: X Athena Widget Set")

    set_urls("https://www.x.org/archive/individual/lib/libXaw-$(version).tar.bz2")
    add_versions("1.0.14", "76aef98ea3df92615faec28004b5ce4e5c6855e716fa16de40c32030722a6f8e")

    if is_plat("macosx", "linux") then
        add_deps("libxmu", "libxpm")
    end

    if is_plat("linux") then
        add_extsources("apt::libxaw7-dev", "pacman::libxaw")
    end

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("XawInitializeWidgetSet", {includes = "X11/Xaw/XawInit.h"}))
    end)
