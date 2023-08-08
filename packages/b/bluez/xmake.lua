package("bluez")
    set_homepage("http://www.bluez.org")
    set_description("Library for the Bluetooth protocol stack for Linux")
    set_license("GPL-2.0")

    add_urls("https://git.kernel.org/pub/scm/bluetooth/bluez.git")
    add_versions("5.68", "d764f78f27653bc1df71c462e9aca7a18bc75f9f")

    add_includedirs("include")

    on_install("linux", function (package)
        os.cp("lib/*.h", package:installdir("include", "bluetooth"))

        -- Includes in the library have the formats "bluetooth.h" and <bluetooth/bluetooth.h>
        -- So includedirs must be set using the package install location
        io.writefile("xmake.lua", format([[
            target("bluez2")
                set_kind("$(kind)")
                add_files("lib/*.c")
                add_includedirs("%s", ".")
        ]], package:installdir("include")))

        local configs = {}
        configs.kind = package:config("shared") and "shared" or "static"

        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("str2ba", {includes = "bluetooth/bluetooth.h"}))
    end)
