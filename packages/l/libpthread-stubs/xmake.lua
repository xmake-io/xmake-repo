package("libpthread-stubs")

    set_homepage("https://www.x.org/")
    set_description("X.Org: pthread-stubs.pc")

    set_urls("https://xcb.freedesktop.org/dist/libpthread-stubs-$(version).tar.bz2")
    add_versions("0.4", "e4d05911a3165d3b18321cc067fdd2f023f06436e391c6a28dff618a78d2e733")

    add_deps("pkg-config")

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        local envs = {PKG_CONFIG_PATH = path.join(package:installdir(), "lib", "pkgconfig")}
        os.vrunv("pkg-config", {"--exists", "pthread-stubs"}, {envs = envs})
    end)

