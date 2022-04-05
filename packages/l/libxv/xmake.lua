package("libxv")

    set_homepage("https://www.x.org/")
    set_description("X.Org: X Video (Xv) extension")

    set_urls("https://www.x.org/archive/individual/lib/libXv-$(version).tar.bz2")
    add_versions("1.0.11", "d26c13eac99ac4504c532e8e76a1c8e4bd526471eb8a0a4ff2a88db60cb0b088")

    if is_plat("linux") then
        add_extsources("apt::libxv-dev", "pacman::libxv")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "libx11", "libxext", "xorgproto")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("XvEvent", {includes = {"X11/Xlib.h", "X11/extensions/Xvlib.h"}}))
    end)
