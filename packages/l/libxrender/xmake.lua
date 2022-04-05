package("libxrender")

    set_homepage("https://www.x.org/")
    set_description("X.Org: Library for the Render Extension to the X11 protocol")

    set_urls("https://www.x.org/archive/individual/lib/libXrender-$(version).tar.bz2")
    add_versions("0.9.10", "c06d5979f86e64cabbde57c223938db0b939dff49fdb5a793a1d3d0396650949")

    if is_plat("linux") then
        add_extsources("apt::libxrender-dev")
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
        assert(package:has_ctypes("XRenderColor", {includes = "X11/extensions/Xrender.h"}))
    end)
