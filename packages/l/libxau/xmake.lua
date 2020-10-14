package("libxau")

    set_homepage("https://www.x.org/")
    set_description("X.Org: A Sample Authorization Protocol for X")

    set_urls("https://www.x.org/archive/individual/lib/libXau-$(version).tar.bz2")
    add_versions("1.0.9", "ccf8cbf0dbf676faa2ea0a6d64bcc3b6746064722b606c8c52917ed00dcb73ec")

    add_deps("autoconf", "util-macros", "xorgproto")

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("Xauth", {includes = "X11/Xauth.h"}))
    end)
