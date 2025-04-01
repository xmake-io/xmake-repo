package("libxshmfence")

    set_homepage("https://www.x.org/")
    set_description("X.Org: Shared memory 'SyncFence' synchronization primitive")

    set_urls("https://www.x.org/archive/individual/lib/libxshmfence-$(version).tar.gz")
    add_versions("1.3", "7eb3d46ad91bab444f121d475b11b39273142d090f7e9ac43e6a87f4ff5f902c")
    add_versions("1.3.3", "6233ccd9fa80198835efc3039cdf8086ab2b218b17e77ebdb0a19913fcee58d3")

    if is_plat("linux") then
        add_extsources("apt::libxshmfence-dev")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "xorgproto")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("struct xshmfence", {includes = "X11/xshmfence.h"}))
    end)
