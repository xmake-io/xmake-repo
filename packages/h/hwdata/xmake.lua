package("hwdata")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/vcrhonek/hwdata")
    set_description("hwdata contains various hardware identification and configuration data, such as the pci.ids and usb.ids databases.")
    set_license("GPL-2.0-or-later")

    add_urls("https://github.com/vcrhonek/hwdata/archive/refs/tags/$(version).tar.gz",
             "https://github.com/vcrhonek/hwdata.git")

    add_versions("v0.397", "09eee39e73a63ab27af651ab6afdd13d6e5c3485872f2cd406b35e4d80ffdb0b")

    on_install("linux", "bsd", function (package)
        if package:is_plat("bsd") then
            io.replace("Makefile", "install -m 644", "ginstall -m 644", {plain = true})
        end
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        assert(os.isfile(package:installdir("share/hwdata/pnp.ids")))
    end)
