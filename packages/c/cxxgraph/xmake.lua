package("cxxgraph")
    set_kind("library", {headeronly = true})
    set_homepage("https://zigrazor.github.io/CXXGraph")
    set_description("Header-Only C++ Library for Graph Representation and Algorithms")
    set_license("AGPL-3.0")

    add_urls("https://github.com/ZigRazor/CXXGraph/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ZigRazor/CXXGraph.git")

    add_versions("v4.1.0", "1f6601abfcb692f35bfe14f2a34b2302f70213a257b0f7d541a110d6bd460040")
    add_versions("v3.1.0", "54838d0d35a6f2685cf45e50e888146aef3c1a10fbbdddb939b3985c7953087a")

    if on_check then
        on_check("windows", "wasm", function (package)
            if package:is_plat("windows") then
                local vs = package:toolchain("msvc"):config("vs")
                assert(vs and tonumber(vs) >= 2022, "package(cxxgraph): need vs >= 2022")
            elseif package:is_plat("wasm") then
                assert(not package:version("4.1.0"), "package(cxxgraph/4.1.0): Unsupported platform")
            end
        end)
    end

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("CXXGraph::Graph<int>", {configs = {languages = "c++20"}, includes = {"algorithm", "CXXGraph/CXXGraph.hpp"}}))
    end)
