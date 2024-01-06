package("igraph")
    set_homepage("https://igraph.org")
    set_description("Library for the analysis of networks")

    add_urls("https://github.com/igraph/igraph/archive/refs/tags/$(version).tar.gz",
             "https://github.com/igraph/igraph.git")

    add_versions("0.10.8", "5320c53bf422e235acd25958cf913c2a3fcb73cfc3b0901e4cff681e4e160946")
    add_patches("0.10.8", path.join(os.scriptdir(), "patches", "0.10.8", "IGRAPH_VERSION.patch"), 
                "edeebac3f0903792d286d1ab3b152fa17f304307eb3deafde566dfc6ec614773")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("igraph_vector_init", {includes = "igraph/igraph.h"}))
    end)
