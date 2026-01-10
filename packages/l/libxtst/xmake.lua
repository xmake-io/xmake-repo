package("libxtst")
    set_homepage("https://www.x.org/")
    set_description("X.Org: Client API for the XTEST & RECORD extensions")
    set_license("MIT")

    set_urls("https://www.x.org/archive/individual/lib/libXtst-$(version).tar.gz")
    add_versions("1.2.3", "a0c83acce02d4923018c744662cb28eb0dbbc33b4adc027726879ccf68fbc2c2")
    add_versions("1.2.5", "244ba6e1c5ffa44f1ba251affdfa984d55d99c94bb925a342657e5e7aaf6d39c")

    if is_plat("linux") then
        add_extsources("apt::libxtst-dev", "pacman::libxtst")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "util-macros", "xorgproto")
    end

    on_load(function (package)
        package:add("deps", "libxi", { configs = { shared = package:config("shared") } })
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--enable-specs=no"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("XRecordRange8", {includes = {"X11/Xlib.h", "X11/extensions/record.h"}}))
    end)
