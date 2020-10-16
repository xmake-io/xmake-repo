package("libxcb")

    set_homepage("https://www.x.org/")
    set_description("X.Org: Interface to the X Window System protocol")

    set_urls("https://xcb.freedesktop.org/dist/libxcb-$(version).tar.bz2")
    add_versions("1.13.1", "a89fb7af7a11f43d2ce84a844a4b38df688c092bf4b67683aef179cdf2a647c4")

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
