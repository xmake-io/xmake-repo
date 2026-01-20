package("libxdamage")
    set_homepage("https://www.x.org/")
    set_description("X.Org: X Damage Extension library")

    set_urls("https://www.x.org/archive/individual/lib/libXdamage-$(version).tar.gz")
    add_versions("1.1.5", "630ec53abb8c2d6dac5cd9f06c1f73ffb4a3167f8118fdebd77afd639dbc2019")
    add_versions("1.1.6", "2afcc139eb6eb926ffe344494b1fc023da25def42874496e6e6d3aa8acef8595")

    if is_plat("linux") then
        add_extsources("apt::libxdamage-dev")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "xorgproto")
    end

    on_load(function (package)
        package:add("deps", "libx11", "libxfixes", { configs = { shared = package:config("shared") } })
    end)

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
