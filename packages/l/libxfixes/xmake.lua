package("libxfixes")

    set_homepage("https://www.x.org/")
    set_description("X.Org: Header files for the XFIXES extension")

    set_urls("https://www.x.org/archive/individual/lib/libXfixes-$(version).tar.bz2")
    add_versions("5.0.3", "de1cd33aff226e08cefd0e6759341c2c8e8c9faf8ce9ac6ec38d43e287b22ad6")

    if is_plat("linux") then
        add_extsources("apt::libxfixes-dev", "pacman::libxfixes")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "libx11", "xorgproto")
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
        assert(package:has_ctypes("XFixesSelectionNotifyEvent", {includes = "X11/extensions/Xfixes.h"}))
    end)
