package("cxxgraph")
    set_kind("library", {headeronly = true})
    set_homepage("https://zigrazor.github.io/CXXGraph")
    set_description("Header-Only C++ Library for Graph Representation and Algorithms")
    set_license("AGPL-3.0")

    add_urls("https://github.com/ZigRazor/CXXGraph/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ZigRazor/CXXGraph.git")

    add_versions("v3.1.0", "54838d0d35a6f2685cf45e50e888146aef3c1a10fbbdddb939b3985c7953087a")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("CXXGraph::Graph<int>", {configs = {languages = "c++20"}, includes = {"algorithm", "CXXGraph/CXXGraph.hpp"}}))
    end)
