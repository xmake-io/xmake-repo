package("libxinerama")

    set_homepage("https://www.x.org/")
    set_description("X.Org: API for Xinerama extension to X11 Protocol")

    set_urls("https://www.x.org/archive/individual/lib/libXinerama-$(version).tar.bz2")
    add_versions("1.1.4", "0008dbd7ecf717e1e507eed1856ab0d9cf946d03201b85d5dcf61489bb02d720")

    if is_plat("linux") then
        add_extsources("apt::libxinerama-dev")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "libx11", "libxext", "xorgproto")
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
        assert(package:has_ctypes("XineramaScreenInfo", {includes = "X11/extensions/Xinerama.h"}))
    end)
