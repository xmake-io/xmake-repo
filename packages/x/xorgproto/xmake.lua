package("xorgproto")

    set_homepage("https://www.x.org/")
    set_description("X.Org: Protocol Headers")

    set_urls("https://xorg.freedesktop.org/archive/individual/proto/xorgproto-$(version).tar.bz2")
    add_versions("2019.2", "46ecd0156c561d41e8aa87ce79340910cdf38373b759e737fcbba5df508e7b8e")

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
