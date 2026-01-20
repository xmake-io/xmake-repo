package("libxt")
    set_homepage("https://gitlab.freedesktop.org/xorg/lib/libxt")
    set_description("X.Org: X Toolkit Intrinsics library")

    add_urls("https://www.x.org/archive/individual/lib/libXt-$(version).tar.gz")
    add_versions("1.2.1", "6da1bfa9dd0ed87430a5ce95b129485086394df308998ebe34d98e378e3dfb33")
    add_versions("1.3.1", "cf2212189869adb94ffd58c7d9a545a369b83d2274930bfbe148da354030b355")

    if is_plat("linux") then
        add_extsources("apt::libxt-dev", "pacman::libxt")
    end

    add_deps("libsm")

    on_load(function (package)
        package:add("deps", "libx11", { configs = { shared = package:config("shared") } })
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
        assert(package:has_cfuncs("XtConvertAndStore", {includes = "X11/Intrinsic.h"}))
    end)
