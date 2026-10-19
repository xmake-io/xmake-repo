package("xlang")
    set_kind("addon")
    set_homepage("https://github.com/xmake-addons/xlang")
    set_description("Xclang cross-toolchain support for Xmake")
    set_license("Apache-2.0")

    add_urls("https://github.com/xmake-addons/xlang/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-addons/xlang.git")
    add_versions("v1.0.1", "ac97300903540af03378537677aba63244b3fe8221efe8c9433974ecbcd4668d")

    on_test(function (package)
        assert(package:has_addon({toolchains = "xclang"}))
    end)
