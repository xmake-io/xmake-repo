package("libxss")
    set_homepage("https://gitlab.freedesktop.org/xorg/lib/libxscrnsaver")
    set_description("XScreenSaver - X11 Screen Saver extension client library")
    set_license("MIT")

    add_urls("https://gitlab.freedesktop.org/xorg/lib/libxscrnsaver/-/archive/libXScrnSaver-$(version)/libxscrnsaver-libXScrnSaver-$(version).tar.gz", {alias = "release"})
    add_urls("https://gitlab.freedesktop.org/xorg/lib/libxscrnsaver.git", {alias = "git"})

    add_versions("release:1.2.5", "127cd6862cfe7bcd14aa882e82695b3ca2b05e0cc9c208cadbbfb0f6a1114734")

    add_versions("git:1.2.5", "libXScrnSaver-1.2.5")

    if is_plat("linux") then
        add_extsources("apt::libxss-dev")
    end

    if is_plat("macosx", "linux", "bsd", "cross") then
        add_deps("automake", "autoconf", "libtool", "xorgproto")
    end

    on_load(function (package)
        package:add("deps", "libx11", "libxext", { configs = { shared = package:config("shared") } })
    end)

    on_install("macosx", "linux", "bsd", "cross", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules"}
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:config("pic") then
            table.insert(configs, "--with-pic")
        end
        if package:is_cross() then
            table.insert(configs, "--disable-malloc0returnsnull")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("XScreenSaverQueryInfo", {includes = "X11/extensions/scrnsaver.h"}))
    end)
