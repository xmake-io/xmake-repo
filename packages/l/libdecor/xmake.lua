package("libdecor")
    set_homepage("https://gitlab.freedesktop.org/libdecor/libdecor")
    set_description("A client-side decorations library for Wayland client")
    set_license("MIT")

    add_urls("https://gitlab.freedesktop.org/libdecor/libdecor/-/archive/$(version)/libdecor-$(version).tar.gz")
    add_versions("0.1.0", "1d5758cb49dcb9ceaa979ad14ceb6cdf39282af5ce12ebe6073dd193d6b2fb5e")
    add_patches("0.1.0", path.join(os.scriptdir(), "patches", "0.1.0", "include.patch"), "019fcf7cf04c0d89cec879342ecb7911fd99333b68b7f6d4409fb641917a3f5e")
    add_versions("0.1.1", "82adece5baeb6194292b0d1a91b4b3d10da41115f352a5e6c5844b20b88a0512")
    add_patches("0.1.1", path.join(os.scriptdir(), "patches", "0.1.1", "include.patch"), "56de33e118c0d4312c9297bc6b72836b08865205f9e9c9778cbd1107142fd0eb")
    add_versions("0.2.0", "455acc1e1af43657fadbc79a9bac41e2d465ad1abdf1a6f8405e461350046f22")
    add_patches("0.2.0", path.join(os.scriptdir(), "patches", "0.2.0", "include.patch"), "63fdd1084278cbc5757463deb4c97c8ad71e0d38d300af251956510f98630534")

    if is_plat("linux") then 
        add_extsources("apt::libdecor-0-dev", "pacman::libdecor")
    end

    add_deps("meson >=0.47", "ninja", "wayland >=1.18", "wayland-protocols >=1.15", "cairo", "pango", "pkg-config")

    add_includedirs("include/libdecor-0")

    add_configs("dbus", {description = "Use D-Bus to fetch cursor settings", default = true, type = "boolean"})
    add_configs("gtk", {description = "Build GTK plugin", default = true, type = "boolean"})

    on_load("linux", function (package)
        if package:config("dbus") then
            package:add("deps", "dbus")
        end
        if package:config("gtk") then
            package:add("deps", "gtk+3")
        end
    end)

    on_install("linux", function (package)
        local configs = {
            "-Ddemo=false",
            "-Ddbus=" .. (package:config("dbus") and "enabled" or "disabled"),
        }

        local version = package:version()
        if version:major() > 0 or version:minor() >= 2 then
            -- GTK plugin is supported since 0.2.0
            table.insert(configs, "-Dgtk=" .. (package:config("gtk") and "enabled" or "disabled"))
        end

        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("libdecor_new", {includes = "libdecor.h"}))
    end)
