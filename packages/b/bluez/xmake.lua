package("bluez")
    set_homepage("http://www.bluez.org")
    set_description("Library for the Bluetooth protocol stack for Linux")
    set_license("GPL-2.0-or-later")

    add_urls("https://git.kernel.org/pub/scm/bluetooth/bluez.git")
    add_versions("5.79", "0845b8f6ef2ac004b1c953cf4fe4ca3458cd8e36")
    add_versions("5.78", "e8575b6196ab8d457342c2d332bd402f2bedd9f7")
    add_versions("5.77", "68864d1aa818aca00d67f7a4d6078344483e9509")
    add_versions("5.76", "f6241a10e460ab14fa3e2b943460673df0ded603")
    add_versions("5.75", "249216dce21f97d92144f0f72cc8b97f25203184")
    add_versions("5.74", "f1a7ab0ef75b9e11f04a028b50d4172a4b5f8601")
    add_versions("5.73", "19f8fcdc2084048bebe5bd9ea4fb97f7ece16df0")
    add_versions("5.72", "770ad5614e7e8074133e6f563495ce4822f63fe4")
    add_versions("5.71", "04ecf635ffaa2f7f8bca89cec3a0fbdbeb016dc9")
    add_versions("5.70", "c56970cbea3b5482a586b7570e79a28e7d84d295")
    add_versions("5.69", "bbe41152d4c1c3fd608f3d933dba445a790a5331")
    add_versions("5.68", "d764f78f27653bc1df71c462e9aca7a18bc75f9f")

    on_install("linux", function (package)
        os.cp("lib/*.h", "bluetooth/")
        io.writefile("xmake.lua", [[
            target("bluez")
                set_kind("$(kind)")
                add_files("lib/*.c")
                add_includedirs(".")
                add_headerfiles("lib/(*.h)", {prefixdir = "bluetooth"})
        ]])

        local configs = {}
        configs.kind = package:config("shared") and "shared" or "static"
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("str2ba", {includes = "bluetooth/bluetooth.h"}))
    end)
