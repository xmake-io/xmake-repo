package("clib")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/aheck/clib")
    set_description("Header-only library for C99 that implements the most important classes from GLib: GList, GHashTable and GString.")
    set_license("MIT")

    add_urls("https://github.com/aheck/clib.git")
    add_versions("2022.12.25", "fea69de62f0c2e01a46d02208073e2e976a5a237")

    on_install(function (package)
        os.cp("src/*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("g_string_insert", {includes = "gstring.h"}))
    end)
