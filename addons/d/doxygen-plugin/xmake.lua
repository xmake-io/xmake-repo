package("doxygen-plugin")
    set_kind("addon")
    set_homepage("https://github.com/xmake-addons/doxygen-plugin")
    set_description("The documentation addon, it provides the `xmake doxygen` command to generate the doxygen document.")
    set_license("Apache-2.0")

    add_urls("https://github.com/xmake-addons/doxygen-plugin/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-addons/doxygen-plugin.git")
    add_versions("v1.0.0", "ddf1077d196552fa8d46f71048cec13191e60ffb93d2068d9d73314fa5905424")

    on_test(function (package)
        assert(package:has_addon({plugins = "doxygen"}))

        os.vrun("xmake doxygen --help")
    end)
