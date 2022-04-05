package("xorgproto")

    set_kind("library", {headeronly = true})
    set_homepage("https://www.x.org/")
    set_description("X.Org: Protocol Headers")

    set_urls("https://xorg.freedesktop.org/archive/individual/proto/xorgproto-$(version).tar.bz2")
    add_versions("2019.2", "46ecd0156c561d41e8aa87ce79340910cdf38373b759e737fcbba5df508e7b8e")
    add_versions("2021.3", "4c732b14fc7c7db64306374d9e8386d6172edbb93f587614df1938b9d9b9d737")
    add_versions("2021.5", "aa2f663b8dbd632960b24f7477aa07d901210057f6ab1a1db5158732569ca015")

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
