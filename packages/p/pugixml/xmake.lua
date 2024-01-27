package("pugixml")

    set_homepage("https://pugixml.org/")
    set_description("Light-weight, simple and fast XML parser for C++ with XPath support")
    set_license("MIT")

    add_urls("https://github.com/zeux/pugixml/archive/$(version).tar.gz",
             "https://github.com/zeux/pugixml.git")
    add_versions("v1.11.4", "017139251c122dbff400a507cddc4cb74120a431a50c6c524f30edcc5b331ade")
    add_versions("v1.13", "5c5ad5d7caeb791420408042a7d88c2c6180781bf218feca259fd9d840a888e1")
    add_versions("v1.14", "2f10e276870c64b1db6809050a75e11a897a8d7456c4be5c6b2e35a11168a015")

    add_deps("cmake")

    on_install("windows", "linux", "macosx", "mingw", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DSTATIC_CRT=" .. ((package:config("runtimes") and package:has_runtime("MT", "MTd")) or (package:config("vs_config") and package:config("vs_config"):startswith("MT")) and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                pugi::xml_document doc;
                pugi::xpath_node_set nset;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "pugixml.hpp"}))
    end)
