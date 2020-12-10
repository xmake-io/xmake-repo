package("libxtst")

    set_homepage("https://www.x.org/")
    set_description("X.Org: Client API for the XTEST & RECORD extensions")
    set_license("MIT")

    set_urls("https://www.x.org/archive/individual/lib/libXtst-$(version).tar.bz2")
    add_versions("1.2.3", "4655498a1b8e844e3d6f21f3b2c4e2b571effb5fd83199d428a6ba7ea4bf5204")

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "util-macros", "libxi", "xorgproto")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--enable-specs=no"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("XRecordRange8", {includes = {"X11/Xlib.h", "X11/extensions/record.h"}}))
    end)
