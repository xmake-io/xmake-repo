package("libpciaccess")
    set_homepage("https://gitlab.freedesktop.org/xorg/lib/libpciaccess")
    set_description("Generic PCI access library")
    set_license("MIT")

    add_urls("https://gitlab.freedesktop.org/xorg/lib/libpciaccess/-/archive/libpciaccess-$(version)/libpciaccess-libpciaccess-$(version).tar.gz",
             "https://gitlab.freedesktop.org/xorg/lib/libpciaccess.git")

    add_versions("0.18.1", "a395317730e0e8d5e71419d4d1256a89e32c2fa793607b63c4d0fb497ae34602")

    add_configs("zlib", {description = "Enable zlib support to read gzip compressed pci.ids.", default = false, type = "boolean"})
    add_configs("linux_rom_fallback", {description = "Enable support for falling back to /dev/mem for roms on Linux.", default = false, type = "boolean"})

    add_deps("meson", "ninja")
    add_deps("hwdata", {private = true})

    on_load(function (package)
        if package:config("zlib") then
            package:add("deps", "zlib")
        end
    end)

    on_install("linux", "bsd", function (package)
        local configs = {}
        table.insert(configs, "-Dzlib=" .. (package:config("zlib") and "enabled" or "disabled"))
        table.insert(configs, "-Dlinux-rom-fallback=" .. (package:config("linux_rom_fallback") and "true" or "false"))
        table.insert(configs, "-Dpci-ids=" .. package:dep("hwdata"):installdir("share/hwdata"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pci_system_init", {includes = "pciaccess.h"}))
    end)
