package("libxext")

    set_homepage("https://www.x.org/")
    set_description("X.Org: Library for common extensions to the X11 protocol")

    set_urls("https://www.x.org/archive/individual/lib/libXext-$(version).tar.bz2")
    add_versions("1.3.4", "59ad6fcce98deaecc14d39a672cf218ca37aba617c9a0f691cac3bcd28edf82b")

    if is_plat("linux") then
        add_extsources("apt::libxext-dev")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "libx11", "xorgproto")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--enable-specs=no"}
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:config("pic") then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("XShapeEvent", {includes = "X11/extensions/shape.h"}))
    end)
