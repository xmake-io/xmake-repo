package("libice")

    set_homepage("https://gitlab.freedesktop.org/xorg/lib/libice")
    set_description("X.Org: Inter-Client Exchange Library")

    add_urls("https://www.x.org/archive/individual/lib/libICE-$(version).tar.gz")
    add_versions("1.0.10", "1116bc64c772fd127a0d0c0ffa2833479905e3d3d8197740b3abd5f292f22d2d")
    add_versions("1.1.2", "1da62f732f8679c20045708a29372b82dff9e7eceee543ed488b845002b3b0ff")

    if is_plat("linux") then
        add_extsources("apt::libice-dev", "pacman::libice")
    end

    add_deps("xtrans")

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--enable-docs=no",
                         "--enable-specs=no"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("IceOpenConnection", {includes = "X11/ICE/ICElib.h"}))
    end)
