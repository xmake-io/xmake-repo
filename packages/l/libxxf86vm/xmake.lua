package("libxxf86vm")

    set_homepage("https://www.x.org/")
    set_description("X.Org: XFree86-VidMode X extension")

    set_urls("https://www.x.org/archive/individual/lib/libXxf86vm-$(version).tar.bz2")
    add_versions("1.1.4", "afee27f93c5f31c0ad582852c0fb36d50e4de7cd585fcf655e278a633d85cd57")

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
