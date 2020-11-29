package("libxcb")

    set_homepage("https://www.x.org/")
    set_description("X.Org: Interface to the X Window System protocol")

    set_urls("https://xcb.freedesktop.org/dist/libxcb-$(version).tar.gz")
    add_versions("1.13.1", "f09a76971437780a602303170fd51b5f7474051722bc39d566a272d2c4bde1b5")
    add_versions("1.14", "2c7fcddd1da34d9b238c9caeda20d3bd7486456fc50b3cc6567185dbd5b0ad02")

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "python 3.x", "xcb-proto", "libpthread-stubs", "libxau", "libxdmcp")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--enable-dri3",
                         "--enable-ge",
                         "--enable-xevie",
                         "--enable-xprint",
                         "--enable-selinux",
                         "--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--enable-devel-docs=no",
                         "--with-doxygen=no"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xcb_connect", {includes = "xcb/xcb.h"}))
    end)
