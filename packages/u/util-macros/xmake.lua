package("util-macros")

    set_homepage("https://www.x.org/")
    set_description("X.Org: Set of autoconf macros used to build other xorg packages")

    set_urls("https://www.x.org/archive/individual/util/util-macros-$(version).tar.bz2")
    add_versions("1.19.2", "d7e43376ad220411499a79735020f9d145fdc159284867e99467e0d771f3e712")
    add_versions("1.19.3", "0f812e6e9d2786ba8f54b960ee563c0663ddbe2434bf24ff193f5feab1f31971")

    add_deps("pkg-config")

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var")}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        local envs = {PKG_CONFIG_PATH = path.join(package:installdir(), "share", "pkgconfig")}
        os.vrunv("pkg-config", {"--exists", "xorg-macros"}, {envs = envs})
    end)

