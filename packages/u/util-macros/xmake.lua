package("util-macros")
    set_homepage("https://www.x.org/")
    set_description("X.Org: Set of autoconf macros used to build other xorg packages")

    add_urls("https://www.x.org/archive/individual/util/util-macros-$(version).tar.gz",
             "https://xorg.freedesktop.org/archive/individual/util/util-macros-$(version).tar.gz")
    add_versions("1.19.3", "624bb6c3a4613d18114a7e3849a3d70f2d7af9dc6eabeaba98060d87e3aef35b")
    add_versions("1.20.0", "8daf36913d551a90fd1013cb078401375dabae021cb4713b9b256a70f00eeb74")

    if is_plat("linux") then
        add_extsources("apt::xutils-dev", "pkgconfig::xorg-macros")
    end

    add_deps("pkg-config")

    on_install("macosx", "linux", "bsd", "cross", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var")}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        local envs = {PKG_CONFIG_PATH = path.join(package:installdir(), "share", "pkgconfig")}
        os.vrunv("pkg-config", {"--exists", "xorg-macros"}, {envs = envs})
    end)

