package("bluez")
    set_homepage("http://www.bluez.org")
    set_description("Library for the Bluetooth protocol stack for Linux")
    set_license("GPL-2.0-or-later")

    add_urls("https://git.kernel.org/pub/scm/bluetooth/bluez.git")
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
