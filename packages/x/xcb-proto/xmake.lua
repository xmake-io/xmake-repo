package("xcb-proto")

    set_homepage("https://www.x.org/")
    set_description("X.Org: XML-XCB protocol descriptions for libxcb code generation")

    set_urls("https://xorg.freedesktop.org/archive/individual/proto/xcb-proto-$(version).tar.gz",
             "https://xcb.freedesktop.org/dist/xcb-proto-$(version).tar.gz")
    add_versions("1.13", "0698e8f596e4c0dbad71d3dc754d95eb0edbb42df5464e0f782621216fa33ba7")
    add_versions("1.14", "1c3fa23d091fb5e4f1e9bf145a902161cec00d260fabf880a7a248b02ab27031")
    add_versions("1.14.1", "85cd21e9d9fbc341d0dbf11eace98d55d7db89fda724b0e598855fcddf0944fd")
    add_versions("1.15.2", "6b1ed9cd7cf35e37913eeecca37e5b85b14903002942b3e332f321335c27a8eb")

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "python 3.x")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-silent-rules",
                         "PYTHON=python3"}
        import("package.tools.autoconf").install(package, configs)
        local version = package:dep("python"):version()
        local pyver = ("python%d.%d"):format(version:major(), version:minor())
        package:addenv("PYTHONPATH", path.join(package:installdir("lib"), pyver, "site-packages"))
    end)

    on_test(function (package)
        local envs = {PKG_CONFIG_PATH = path.join(package:installdir(), "lib", "pkgconfig")}
        os.vrunv("pkg-config", {"--exists", "xcb-proto"}, {envs = envs})
    end)
