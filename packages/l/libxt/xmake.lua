package("libxt")

    set_homepage("https://gitlab.freedesktop.org/xorg/lib/libxt")
    set_description("X.Org: X Toolkit Intrinsics library")

    add_urls("https://www.x.org/archive/individual/lib/libXt-$(version).tar.gz")
    add_versions("1.2.1", "6da1bfa9dd0ed87430a5ce95b129485086394df308998ebe34d98e378e3dfb33")

    if is_plat("linux") then
        add_extsources("apt::libxt-dev")
    end

    add_deps("libx11", "libsm")

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("XtConvertAndStore", {includes = "X11/Intrinsic.h"}))
    end)
