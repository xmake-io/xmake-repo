package("libgda")

    set_homepage("https://github.com/GNOME/libgda/tree/master")
    set_description("libgda - an interface to the GDA architecture")
    set_license("LGPL-2.0")

    add_urls("https://github.com/GNOME/libgda.git")
    add_versions("2024.08.12", "97fec3090dc86d4b69f62f09d87db9dbcc864fa2")

    add_includedirs("include", "include/libgda-6.0", "include/libgda-6.0/libgda")

    add_deps("meson", "ninja", "libxml2", "gettext", "sqlite3", "json-glib", "pcre2", "iso-codes")
    on_install("linux", function (package)
        local configs = {"-Dui=false", "-Dvapi=false", "-Dwerror=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs, {packagedeps = {"glib"}})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gda_init", {includes = "libgda/libgda.h"}))
    end)
