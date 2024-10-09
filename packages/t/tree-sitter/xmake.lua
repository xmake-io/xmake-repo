package("tree-sitter")
    set_homepage("https://tree-sitter.github.io/")
    set_description("An incremental parsing system for programming tools")
    set_license("MIT")

    add_urls("https://github.com/tree-sitter/tree-sitter/archive/refs/tags/$(version).zip",
             "https://github.com/tree-sitter/tree-sitter.git")

    add_versions("v0.24.2", "e3321bde397ba9ec7450c59912abb120d3d73f9381100fd2c6a3fc20668f67e2")
    add_versions("v0.23.0", "e9f2772b12d4b12a0db5542ce72e8c85a34e397f2c3fd7b3fa08814f71fd35b3")
    add_versions("v0.22.6", "eb2d8bfcb6d21b820ac88add96d71ef9ebaec9d2a171b86a48c27c0511a17e4e")
    add_versions("v0.22.5", "b8c0da9f5cafa3214547bc3bbfa0d0f05a642f9d0c045e505a940cf487300849")
    add_versions("v0.22.2", "df0cd4aacc53b6feb9519dd4b74a7a6c8b7f3f7381fcf7793250db3e5e63fb80")
    add_versions("v0.21.0", "874794e6b3b985f7f9e87dfe29e4bfdbe5c0339e67740f35dfc4fa85804ba708")

    on_install(function(package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function(package)
        assert(package:has_cfuncs("ts_parser_new", {includes = "tree_sitter/api.h"}))
    end)
