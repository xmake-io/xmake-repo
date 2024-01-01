package("graphene")

    set_homepage("http://ebassi.github.io/graphene/")
    set_description("A thin layer of graphic data types")
    set_license("MIT")

    add_urls("https://github.com/ebassi/graphene/releases/download/$(version)/graphene-$(version).tar.xz")
    add_versions("1.10.6", "80ae57723e4608e6875626a88aaa6f56dd25df75024bd16e9d77e718c3560b25")

    add_configs("gobject", {description = "Enable GObject types", default = true, type = "boolean"})

    add_deps("meson", "ninja")
    add_includedirs("include/graphene-1.0", "lib/graphene-1.0/include")
    on_load(function (package)
        if package:config("gobject") then
            package:add("deps", "glib")
            if package:is_plat("windows") then
                package:add("deps", "pkgconf", "libintl")
            elseif package:is_plat("macosx") then
                package:add("deps", "libintl")
                package:add("deps", "libiconv", {system = true})
            elseif package:is_plat("linux") then
                package:add("deps", "libiconv")
            end
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-Dtests=false", "-Dinstalled_tests=false", "-Dintrospection=disabled"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Dgobject_types=" .. (package:config("gobject") and "true" or "false"))
        import("package.tools.meson").install(package, configs, {packagedeps = {"libintl", "libiconv"}})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("graphene_matrix_alloc", {includes = "graphene.h"}))
    end)
