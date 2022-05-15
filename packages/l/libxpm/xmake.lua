package("libxpm")

    set_homepage("https://gitlab.freedesktop.org/xorg/lib/libxpm")
    set_description("X.Org: X Pixmap (XPM) image file format library")

    add_urls("https://www.x.org/archive/individual/lib/libXpm-$(version).tar.gz")
    add_versions("3.5.13", "e3dfb0fb8c1f127432f2a498c7856b37ce78a61e8da73f1aab165a73dd97ad00")

    if is_plat("linux") then
        add_extsources("apt::libxpm-dev", "pacman::libxpm")
    end

    add_deps("libx11", "xorgproto", "gettext")
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
        assert(package:has_cfuncs("XpmCreatePixmapFromData", {includes = "X11/xpm.h"}))
    end)
