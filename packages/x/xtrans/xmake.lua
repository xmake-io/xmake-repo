package("xtrans")
    set_kind("library", {headeronly = true})
    set_homepage("https://www.x.org/")
    set_description("X.Org: X Network Transport layer shared code")

    set_urls("https://www.x.org/archive/individual/lib/xtrans-$(version).tar.gz")
    add_versions("1.4.0", "48ed850ce772fef1b44ca23639b0a57e38884045ed2cbb18ab137ef33ec713f9")

    if is_plat("linux") then
        add_extsources("apt::xtrans-dev", "pacman::xtrans")
    end

    if is_plat("macosx", "linux", "bsd", "cross") then
        add_deps("pkg-config", "util-macros", "xorgproto")
    end

    on_install("macosx", "linux", "bsd", "cross", function (package)
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
