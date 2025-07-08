package("libdisplay-info")
    set_homepage("https://emersion.pages.freedesktop.org/libdisplay-info/")
    set_description("EDID and DisplayID library")
    set_license("MIT")

    add_urls("https://gitlab.freedesktop.org/emersion/libdisplay-info/-/releases/$(version)/downloads/libdisplay-info-$(version).tar.xz",
             "https://gitlab.freedesktop.org/emersion/libdisplay-info.git")

    add_versions("0.2.0", "5a2f002a16f42dd3540c8846f80a90b8f4bdcd067a94b9d2087bc2feae974176")

    add_deps("meson", "ninja")
    add_deps("hwdata", {private = true})

    on_install("linux", function (package)
        local configs = {}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("di_info_parse_edid", {includes = "libdisplay-info/info.h"}))
    end)
