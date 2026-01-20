package("libxv")
    set_homepage("https://www.x.org/")
    set_description("X.Org: X Video (Xv) extension")

    set_urls("https://www.x.org/archive/individual/lib/libXv-$(version).tar.gz")
    add_versions("1.0.11", "c4112532889b210e21cf05f46f0f2f8354ff7e1b58061e12d7a76c95c0d47bb1")
    add_versions("1.0.13", "9a0c31392b8968a4f29a0ad9c51e7ce225bcec3c4cbab9f2a241f921776b2991")

    if is_plat("linux") then
        add_extsources("apt::libxv-dev", "pacman::libxv")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "xorgproto")
    end

    on_load(function (package)
        package:add("deps", "libx11", "libxext", { configs = { shared = package:config("shared") } })
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("XvEvent", {includes = {"X11/Xlib.h", "X11/extensions/Xvlib.h"}}))
    end)
