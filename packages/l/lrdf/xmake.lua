package("lrdf")
    set_homepage("https://github.com/swh/LRDF")
    set_description("A lightweight RDF library with extensions for LADSPA")
    set_license("GPL-2.0")

    add_urls("https://github.com/swh/LRDF/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/swh/LRDF.git")

    add_versions("0.6.1", "d579417c477ac3635844cd1b94f273ee2529a8c3b6b21f9b09d15f462b89b1ef")

    add_deps("raptor2")

    on_install(function(package)
        local configs = {}
        configs.kind = package:config("shared") and "shared" or "static"
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:has_cfuncs("lrdf_read_file", {includes = "lrdf.h"}))
    end)
