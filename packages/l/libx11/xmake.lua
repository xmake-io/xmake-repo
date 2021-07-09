package("libx11")

    set_homepage("https://www.x.org/")
    set_description("X.Org: Core X11 protocol client library")

    set_urls("https://www.x.org/archive/individual/lib/libX11-$(version).tar.bz2")
    add_versions("1.6.9", "9cc7e8d000d6193fa5af580d50d689380b8287052270f5bb26a5fb6b58b2bed1")
    add_versions("1.7.0", "36c8f93b6595437c8cfbc9f08618bcb3041cbd303e140a0013f88e4c2977cb54")

    if is_plat("linux") then
        add_extsources("apt::libx11-dev")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "util-macros", "xtrans", "libxcb", "xorgproto")
    end
    if is_plat("macosx") then
        -- fix sed: RE error: illegal byte sequence
        add_deps("gnu-sed")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--enable-unix-transport",
                         "--enable-tcp-transport",
                         "--enable-ipv6",
                         "--enable-local-transport",
                         "--enable-loadable-i18n",
                         "--enable-xthreads",
                         "--enable-specs=no"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("XOpenDisplay", {includes = "X11/Xlib.h"}))
    end)
