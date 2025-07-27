package("libpciaccess")
    set_homepage("https://gitlab.freedesktop.org/xorg/lib/libpciaccess")
    set_description("Generic PCI access library")
    set_license("MIT")

    add_urls("https://gitlab.freedesktop.org/xorg/lib/libpciaccess/-/archive/libpciaccess-$(version)/libpciaccess-libpciaccess-$(version).tar.gz")
    add_urls("https://gitlab.freedesktop.org/xorg/lib/libpciaccess.git")
    add_versions("0.18.1", "a395317730e0e8d5e71419d4d1256a89e32c2fa793607b63c4d0fb497ae34602")

    add_configs("zlib", {description = "Enable zlib support to read gzip compressed pci.ids.", default = false, type = "boolean"})
    add_configs("linux_rom_fallback", {description = "Enable support for falling back to /dev/mem for roms on Linux.", default = false, type = "boolean"})
    add_configs("pci_ids_path", {description = "Path to pci ids. If relative is assumed relative to $datadir.", default = "hwdata", type = "string"})

    add_deps("meson", "ninja")

    on_load("linux", "bsd", function (package)
        if package:config("zlib") then
            package:add("deps", "zlib")
        end
    end)

    on_install("linux", "bsd", function (package)
        local configs = {}
        if package:is_debug() then
            table.insert(configs, "-Dbuildtype=debug")
        else
            table.insert(configs, "-Dbuildtype=release")
        end

        table.insert(configs, "-Dzlib=" .. (package:config("zlib") and "enabled" or "disabled"))
        table.insert(configs, "-Dlinux-rom-fallback=" .. (package:config("linux_rom_fallback") and "true" or "false"))
        table.insert(configs, "-Dpci-ids=" .. package:config("pci_ids_path"))

        import("package.tools.meson").install(package, configs)
    end)

    on_test("linux", "bsd", function (package)
        assert(package:has_cfuncs("pci_system_init", {includes = "pciaccess.h"}))
    end)
