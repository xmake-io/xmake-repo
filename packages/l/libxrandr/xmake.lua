package("libxrandr")

    set_homepage("https://www.x.org/")
    set_description("X.Org: X Resize, Rotate and Reflection extension library")

    set_urls("https://www.x.org/archive/individual/lib/libXrandr-$(version).tar.bz2")
    add_versions("1.5.2", "8aea0ebe403d62330bb741ed595b53741acf45033d3bda1792f1d4cc3daee023")

    if is_plat("linux") then
        add_extsources("apt::libxrandr-dev")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "libx11", "libxext", "libxrender", "xorgproto")
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
        assert(package:has_ctypes("XRRScreenSize", {includes = "X11/extensions/Xrandr.h"}))
    end)
