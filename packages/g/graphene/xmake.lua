package("graphene")
    set_homepage("http://ebassi.github.io/graphene/")
    set_description("A thin layer of graphic data types")
    set_license("MIT")

    add_urls("https://github.com/ebassi/graphene/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ebassi/graphene.git")

    add_versions("1.10.8", "922dc109d2dc5dc56617a29bd716c79dd84db31721a8493a13a5f79109a4a4ed")

    add_configs("gobject", {description = "Enable GObject types", default = true, type = "boolean"})

    add_includedirs("include/graphene-1.0", "lib/graphene-1.0/include")

    add_deps("meson", "ninja")

    on_load(function (package)
        if package:config("gobject") then
            package:add("deps", "glib")
        end
    end)

    on_install("windows", "macosx", "linux", "cross", "mingw", function (package)
        local configs = {"-Dtests=false", "-Dinstalled_tests=false", "-Dintrospection=disabled"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Dgobject_types=" .. (package:config("gobject") and "true" or "false"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("graphene_matrix_alloc", {includes = "graphene.h"}))
    end)
