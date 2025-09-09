package("hwdata")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/vcrhonek/hwdata")
    set_description("hwdata contains various hardware identification and configuration data, such as the pci.ids and usb.ids databases.")
    set_license("GPL-2.0-or-later")

    add_urls("https://github.com/vcrhonek/hwdata/archive/refs/tags/$(version).tar.gz",
             "https://github.com/vcrhonek/hwdata.git")

    add_versions("v0.399", "74872355e14d5ddc48a0f63036227ffb5f7796a3012c6377ac1fc7432ffe2b41")
    add_versions("v0.397", "09eee39e73a63ab27af651ab6afdd13d6e5c3485872f2cd406b35e4d80ffdb0b")

    if is_plat("bsd") then
        add_patches("v0.397", "patches/v0.397/bsd-makefile.patch", "d14efe1d4727fc6ec4365c0fab10688c83a314776caa8575a61bb0287e92b2c9")
    end

    on_install("linux", "bsd", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        assert(os.isfile(package:installdir("share/hwdata/pnp.ids")))
    end)
