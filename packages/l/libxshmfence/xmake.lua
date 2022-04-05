package("libxshmfence")

    set_homepage("https://www.x.org/")
    set_description("X.Org: Shared memory 'SyncFence' synchronization primitive")

    set_urls("https://www.x.org/archive/individual/lib/libxshmfence-$(version).tar.bz2")
    add_versions("1.3", "b884300d26a14961a076fbebc762a39831cb75f92bed5ccf9836345b459220c7")

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
