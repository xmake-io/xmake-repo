package("libxvmc")

    set_homepage("https://www.x.org/")
    set_description("X.Org: X-Video Motion Compensation API")

    set_urls("https://www.x.org/archive/individual/lib/libXvMC-$(version).tar.bz2")
    add_versions("1.0.12", "6b3da7977b3f7eaf4f0ac6470ab1e562298d82c4e79077765787963ab7966dcd")

    if is_plat("linux") then
        add_extsources("apt::libxvmc-dev")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "util-macros", "libx11", "libxext", "libxv", "xorgproto")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("XvPortID", {includes = {"X11/Xlib.h", "X11/extensions/XvMClib.h"}}))
    end)
