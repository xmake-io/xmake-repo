package("xclang")
    set_kind("addon")
    set_homepage("https://github.com/xmake-addons/xclang")
    set_description("Xclang cross-toolchain support for Xmake")
    set_license("Apache-2.0")

    add_urls("https://github.com/xmake-addons/xclang/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-addons/xclang.git")
    add_versions("v1.0.2", "074cfd2291023d30a830d66a137d4b341afaf839de916e219524463efb8a1cfa")

    on_test(function (package)
        assert(package:has_addon({toolchains = "xclang"}))
    end)
