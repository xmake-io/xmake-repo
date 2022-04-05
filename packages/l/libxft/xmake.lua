package("libxft")

    set_homepage("https://www.x.org/")
    set_description("X.Org: X FreeType library")
    set_license("MIT")

    set_urls("https://www.x.org/archive/individual/lib/libXft-$(version).tar.bz2")
    add_versions("2.3.3", "225c68e616dd29dbb27809e45e9eadf18e4d74c50be43020ef20015274529216")

    if is_plat("linux") then
        add_extsources("apt::libxft-dev")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "fontconfig", "libxrender")
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
        assert(package:has_ctypes("XftFont", {includes = "X11/Xft/Xft.h"}))
    end)
