package("hwdata")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/vcrhonek/hwdata")
    set_description("hwdata contains various hardware identification and configuration data, such as the pci.ids and usb.ids databases.")
    set_license("GPL-2.0-or-later")

    add_urls("https://github.com/vcrhonek/hwdata/archive/refs/tags/$(version).tar.gz",
             "https://github.com/vcrhonek/hwdata.git")

    add_versions("v0.398", "cd52f7eb5c0f438a3605d1799d9f345a2894ad0f269ab6e8441f55e27e80dd78")
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
