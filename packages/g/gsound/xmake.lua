package("gsound")

    set_homepage("https://wiki.gnome.org/Projects/GSound")
    set_description("GSound is a small library for playing system sounds.")
    set_license("LGPL-2.1")

    add_urls("https://gitlab.gnome.org/GNOME/gsound/-/archive/1.0.3/gsound-1.0.3.tar.gz")
    add_versions("1.0.3", "ebee33c77f43bcae87406c20e051acaff08e86f8960c35b92911e243fddc7a0b")

    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    end

    on_load(function (package)
        package:add("deps", "glib", { configs = {shared = package:config("shared")} })
        package:add("deps", "libcanberra", { configs = {shared = package:config("shared")} })
    end)
    add_deps("meson", "ninja")
    
    on_install("linux", function (package)
        local configs = {"-Denable_vala=false", "-Dgtk_doc=false", "-Dintrospection=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gsound_context_new", {includes = "gsound-context.h"}))
    end)
