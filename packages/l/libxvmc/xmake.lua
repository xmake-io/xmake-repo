package("libxvmc")
    set_homepage("https://www.x.org/")
    set_description("X.Org: X-Video Motion Compensation API")

    set_urls("https://www.x.org/archive/individual/lib/libXvMC-$(version).tar.gz")
    add_versions("1.0.12", "024c9ec4f001f037eeca501ee724c7e51cf287eb69ced8c6126e16e7fa9864b5")
    add_versions("1.0.14", "3ad5d2b991219e2bf9b2f85d40b12c16f1afec038715e462f6058af73a9b5ef8")

    if is_plat("linux") then
        add_extsources("apt::libxvmc-dev")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "util-macros", "xorgproto")
    end

    on_load(function (package)
        package:add("deps", "libx11", "libxext", "libxv", { configs = { shared = package:config("shared") } })
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("XvPortID", {includes = {"X11/Xlib.h", "X11/extensions/XvMClib.h"}}))
    end)
