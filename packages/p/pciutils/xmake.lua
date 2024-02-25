package("pciutils")

    set_homepage("https://mj.ucw.cz/sw/pciutils/")
    set_description("The PCI Utilities")
    set_license("GPL-2.0")

    add_urls("https://mj.ucw.cz/download/linux/pci/pciutils-$(version).tar.gz")
    add_versions("3.7.0", "08c27e01030d1fcc700d02bc2ea66c638f58a3d150e45e58852aa82ad4160d84")
    add_versions("3.10.0", "7deabe38ae5fa88a96a8c4947975cf31c591506db546e9665a10dddbf350ead0")

    if is_plat("macosx") then
        add_frameworks("IOKit")
    end
    add_deps("zlib")
    add_deps("libudev", {system = true, optional = true})
    on_install("macosx", "linux", function (package)
        local configs = {"ZLIB=yes"}
        table.insert(configs, "SHARED=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "PREFIX=" .. package:installdir())
        local cflags = {}
        local ldflags = {}
        for _, dep in ipairs(package:orderdeps()) do
            local fetchinfo = dep:fetch()
            if fetchinfo then
                for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    table.insert(cflags, "-I" .. includedir)
                end
                for _, linkdir in ipairs(fetchinfo.linkdirs) do
                    table.insert(ldflags, "-L" .. linkdir)
                end
            end
        end
        import("package.tools.make").build(package, configs, {cflags = cflags, ldflags = ldflags})
        os.vrunv("make", table.join({"install"}, configs))
        os.vrunv("make", table.join({"install-lib"}, configs))
        package:addenv("PATH", "sbin")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pci_init", {includes = "pci/pci.h"}))
    end)
