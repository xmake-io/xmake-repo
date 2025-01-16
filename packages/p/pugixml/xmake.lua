package("pugixml")
    set_homepage("https://pugixml.org/")
    set_description("Light-weight, simple and fast XML parser for C++ with XPath support")
    set_license("MIT")

    add_urls("https://github.com/zeux/pugixml/archive/$(version).tar.gz",
             "https://github.com/zeux/pugixml.git")

    add_versions("v1.11.4", "017139251c122dbff400a507cddc4cb74120a431a50c6c524f30edcc5b331ade")
    add_versions("v1.13", "5c5ad5d7caeb791420408042a7d88c2c6180781bf218feca259fd9d840a888e1")
    add_versions("v1.14", "610f98375424b5614754a6f34a491adbddaaec074e9044577d965160ec103d2e")
    add_versions("v1.15", "b39647064d9e28297a34278bfb897092bf33b7c487906ddfc094c9e8868bddcb")

    add_configs("wchar", {description = "Enable wchar_t mode", default = true, type = "boolean"})
    add_configs("exceptions", {description = "Disable exceptions", default = true, type = "boolean"})

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        if package:is_plat("wasm") and package:config("shared") then
            os.cp(path.join(package:scriptdir(), "port", "sharedwasm.cmake"), "sharedwasm.cmake")
            table.insert(configs, "-DCMAKE_PROJECT_INCLUDE=sharedwasm.cmake")
        end
        if package:config("wchar") then
            io.replace("src/pugiconfig.hpp", "// #define PUGIXML_WCHAR_MODE", "#define PUGIXML_WCHAR_MODE", {plain = true})
        end
        if package:config("exceptions") then
            io.replace("src/pugiconfig.hpp", "// #define PUGIXML_NO_EXCEPTIONS", "#define PUGIXML_NO_EXCEPTIONS", {plain = true})
        end
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
