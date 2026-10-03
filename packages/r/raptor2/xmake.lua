package("raptor2")
    set_homepage("https://librdf.org/raptor/")
    set_description("A library that provides a set of parsers and serializers that generate Resource Description Framework (RDF) triples by parsing syntaxes or serialize the triples into a syntax.")
    set_license("LGPL-2.1-or-later")

    add_urls("https://download.librdf.org/source/raptor2-$(version).tar.gz")

    add_versions("2.0.16", "089db78d7ac982354bdbf39d973baf09581e6904ac4c92a98c5caadb3de44680")

    add_configs("libxslt", {description = "Enable GRDDL parser", default = true, type = "boolean"})

    add_deps("libxml2", "libcurl")
    add_includedirs("include/raptor2")

    on_load(function(package)
        if package:config("libxslt") then
            package:add("deps", "libxslt")
        end
        if not package:config("shared") then
            package:add("defines", "RAPTOR_STATIC", {public = true})
        end
    end)

    on_install("!iphoneos", function(package)
        local configs = {}
        configs.libxslt = package:config("libxslt")
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:has_cfuncs("raptor_world_open", {includes = "raptor2.h"}))
    end)
