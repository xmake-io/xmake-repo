package("libxdamage")

    set_homepage("https://www.x.org/")
    set_description("X.Org: X Damage Extension library")

    set_urls("https://www.x.org/archive/individual/lib/libXdamage-$(version).tar.bz2")
    add_versions("1.1.5", "b734068643cac3b5f3d2c8279dd366b5bf28c7219d9e9d8717e1383995e0ea45")

    if is_plat("linux") then
        add_extsources("apt::libxdamage-dev")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "libx11", "libxfixes", "xorgproto")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules"}
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:config("pic") then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("XDamageNotifyEvent", {includes = "X11/extensions/Xdamage.h"}))
    end)
