package("libxxf86vm")

    set_homepage("https://www.x.org/")
    set_description("X.Org: XFree86-VidMode X extension")

    set_urls("https://www.x.org/archive/individual/lib/libXxf86vm-$(version).tar.gz")
    add_versions("1.1.5", "f3f1c29fef8accb0adbd854900c03c6c42f1804f2bc1e4f3ad7b2e1f3b878128")

    if is_plat("linux") then
        add_extsources("apt::libxxf86vm-dev")
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
        assert(package:has_ctypes("XF86VidModeModeInfo", {includes = {"X11/Xlib.h", "X11/extensions/xf86vmode.h"}}))
    end)
