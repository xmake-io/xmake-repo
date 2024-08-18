package("libgda")

    set_homepage("https://github.com/GNOME/libgda/tree/master")
    set_description("libgda - an interface to the GDA architecture")
    set_license("LGPL-2.0")

    add_urls("https://github.com/GNOME/libgda/archive/refs/tags/LIBGDA_$(version).tar.gz", {alias = "github", version = function (version) return version:gsub("%.", "_") end})
    add_urls("https://github.com/GNOME/libgda.git")
    add_versions("github:6.0.0", "232b3012d24533edf07b873b9d40bbb95a30e08a2afcb4e12723866b21f5a437")

    add_includedirs("include", "include/libgda-6.0", "include/libgda-6.0/libgda")

    if is_plat("linux") then
        add_extsources("pacman::intltool", "apt::intltool")
    end

    add_deps("meson", "ninja", "libxml2", "gettext", "sqlite3", "json-glib", "pcre2")
    on_install("linux", function (package)
        local configs = {"-Dui=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs, {packagedeps = {"glib"}})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gda_init", {includes = "libgda/libgda.h"}))
    end)
