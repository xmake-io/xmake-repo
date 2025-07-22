package("libpthread-stubs")
    set_homepage("https://www.x.org/")
    set_description("X.Org: pthread-stubs.pc")

    add_urls("https://xcb.freedesktop.org/dist/libpthread-stubs-$(version).tar.gz",
             "https://www.x.org/archive/individual/lib/libpthread-stubs-$(version).tar.gz")
    add_versions("0.4", "50d5686b79019ccea08bcbd7b02fe5a40634abcfd4146b6e75c6420cc170e9d9")
    add_versions("0.5", "593196cc746173d1e25cb54a93a87fd749952df68699aab7e02c085530e87747")

    add_deps("pkg-config")

    on_install("macosx", "linux", "bsd", "cross", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        local envs = {PKG_CONFIG_PATH = path.join(package:installdir(), "lib", "pkgconfig")}
        os.vrunv("pkg-config", {"--exists", "pthread-stubs"}, {envs = envs})
    end)
