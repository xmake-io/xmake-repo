package("glib")

    set_homepage("https://developer.gnome.org/glib/")
    set_description("Core application library for C.")

    set_urls("https://download.gnome.org/sources/glib/$(version).tar.xz",
             {version = function (version) return table.concat(table.slice((version):split('%.'), 1, 2), '.') .. "/glib-" .. version end})
    add_versions("2.60.2", "2ef15475060addfda0443a7e8a52b28a10d5e981e82c083034061daf9a8f80d9")

    add_deps("meson", "ninja")

    on_install("macosx", "linux", function (package)
        local configs = {"-Dbsymbolic_functions=false", "-Ddtrace=false"}
        table.insert(configs, "-Dgio_module_dir=" .. path.join(package:installdir(), "lib/gio/modules"))
        if is_plat("macosx") then
            table.insert(configs, "-Diconv=native")
        end
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("g_convert", {includes = "glib.h"}))
    end)
