package("rats-utils")
    set_kind("addon")
    set_homepage("https://github.com/microdee/xmake.rats-utils")
    set_description("Commonly usable very generic utilities for other xmake addons.")
    set_license("MIT")

    add_urls(
        "https://github.com/microdee/xmake.rats-utils/archive/refs/tags/$(version).tar.gz",
        "https://github.com/microdee/xmake.rats-utils.git"
    )
    add_versions("v1.0.3", "158562afe32365b7d41de3e4d8318b28a61f074315b6e3ee8072907d18e1a513")

    on_test(function (package)
        assert(package:has_addon({
            rules   = "rsteps",
            modules = {"rpath", "rsteps", "rtable"}
        }))
    end)
