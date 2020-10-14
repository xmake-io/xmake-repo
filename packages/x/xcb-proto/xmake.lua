package("xcb-proto")

    set_homepage("https://www.x.org/")
    set_description("X.Org: XML-XCB protocol descriptions for libxcb code generation")

    set_urls("https://xcb.freedesktop.org/dist/xcb-proto-$(version).tar.bz2")
    add_versions("1.13", "7b98721e669be80284e9bbfeab02d2d0d54cd11172b72271e47a2fe875e2bde1")

    add_deps("pkg-config", "python 3.x")

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-silent-rules",
                         "PYTHON=python3"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        local envs = {PKG_CONFIG_PATH = path.join(package:installdir(), "lib", "pkgconfig")}
        os.vrunv("pkg-config", {"--exists", "xcb-proto"}, {envs = envs})
    end)
