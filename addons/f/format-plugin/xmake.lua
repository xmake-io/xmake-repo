package("format-plugin")
    set_kind("addon")
    set_homepage("https://github.com/xmake-addons/format-plugin")
    set_description("The code formatting addon, it provides the `xmake format` command based on clang-format.")
    set_license("Apache-2.0")

    add_urls("https://github.com/xmake-addons/format-plugin/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-addons/format-plugin.git")
    add_versions("v1.0.0", "fbe21a2c16ec1127e7d592f9ef264b33f1a2dd025ba4354d79f710781c0938ca")

    on_test(function (package)
        assert(package:has_addon({plugins = "format"}))

        os.vrun("xmake format --help")
    end)
