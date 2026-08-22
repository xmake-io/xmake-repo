package("macro-plugin")
    set_kind("addon")
    set_homepage("https://github.com/xmake-addons/macro-plugin")
    set_description("The macro addon, it provides the `xmake macro` command to record and replay the xmake commands.")
    set_license("Apache-2.0")

    add_urls("https://github.com/xmake-addons/macro-plugin/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-addons/macro-plugin.git")
    add_versions("v1.0.0", "dd0cf85a3c3e40326f50350748b2b3b37ea74123d2406990346dfcebe2b18cc1")

    on_test(function (package)
        assert(package:has_addon({plugins = "macro"}))

        -- the `package` macro is shipped with this addon
        os.vrun("xmake macro --help")
        assert(os.iorun("xmake macro --list"):find("package", 1, true), "the builtin macros are not listed!")
    end)
