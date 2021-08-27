package("pugixml")

    set_homepage("https://pugixml.org/")
    set_description("Light-weight, simple and fast XML parser for C++ with XPath support")
    set_license("MIT")

    add_urls("https://github.com/zeux/pugixml/archive/v$(version).tar.gz")
    add_versions("1.11.4", "017139251c122dbff400a507cddc4cb74120a431a50c6c524f30edcc5b331ade")

    add_deps("cmake")

    on_install("windows", "linux", "macosx", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DSTATIC_CRT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
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
