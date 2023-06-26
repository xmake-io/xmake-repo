package("xorgproto")

    set_kind("library", {headeronly = true})
    set_homepage("https://www.x.org/")
    set_description("X.Org: Protocol Headers")

    set_urls("https://xorg.freedesktop.org/archive/individual/proto/xorgproto-$(version).tar.gz")
    add_versions("2021.5", "be6ddd6590881452fdfa170c1c9ff87209a98d36155332cbf2ccbc431add86ff")
    add_versions("2022.2", "da351a403d07a7006d7bdc8dcfc14ddc1b588b38fb81adab9989a8eef605757b")

    if is_plat("linux") then
        add_extsources("apt::x11proto-dev", "pkgconfig::xproto")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "util-macros")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        local envs = {PKG_CONFIG_PATH = path.join(package:installdir(), "share", "pkgconfig")}
        os.vrunv("pkg-config", {"--exists", "xproto"}, {envs = envs})
        assert(package:has_cincludes("X11/Xproto.h"))
    end)
