package("hwdata")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/vcrhonek/hwdata")
    set_description("hwdata contains various hardware identification and configuration data, such as the pci.ids and usb.ids databases.")
    set_license("GPL-2.0-or-later")

    add_urls("https://github.com/vcrhonek/hwdata/archive/refs/tags/$(version).tar.gz",
             "https://github.com/vcrhonek/hwdata.git")

    add_versions("v0.402", "e390fe2f5f5ef7ed9ccbe62eb7cd40d4ee2b57389e7869c0dc96433c81812e7a")
    add_versions("v0.401", "e9ff93b9807cc014ed8f7f5cb5dc2c31e714058c82ddc59b7355f5c57c9b759e")
    add_versions("v0.400", "05d96821aaae04be4e684eaf9ac22e08efe646321bc64be323b91b66e7e2095c")
    add_versions("v0.399", "74872355e14d5ddc48a0f63036227ffb5f7796a3012c6377ac1fc7432ffe2b41")
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
