package("xtrans")

    set_homepage("https://www.x.org/")
    set_description("X.Org: X Network Transport layer shared code")

    set_urls("https://www.x.org/archive/individual/lib/xtrans-$(version).tar.bz2")
    add_versions("1.4.0", "377c4491593c417946efcd2c7600d1e62639f7a8bbca391887e2c4679807d773")

    if is_plat("linux") then
        add_extsources("apt::xtrans-dev", "pacman::xtrans")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "util-macros", "xorgproto")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--enable-docs=no"}
        -- fedora systems do not provide sys/stropts.h
        io.replace("Xtranslcl.c", "# include <sys/stropts.h>", "# include <sys/ioctl.h>")
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("Xtransaddr", {includes = "X11/Xtrans/Xtrans.h"}))
    end)
