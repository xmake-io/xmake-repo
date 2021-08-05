package("nodesoup")

    set_homepage("https://github.com/olvb/nodesoup")
    set_description("Force-directed graph layout with Fruchterman-Reingold")
    
    add_urls("https://github.com/olvb/nodesoup.git")
    add_versions("2020.09.05", "3158ad082bb0cd1abee75418b12b35522dbca74f")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("nodesoup")
                set_kind("static")
                set_languages("c++14")
                add_files("src/*.cpp")
                add_includedirs("include")
                add_headerfiles("include/nodesoup.hpp")
                add_defines("_USE_MATH_DEFINES")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("nodesoup::adj_list_t", {configs = {languages = "c++14"}, includes = "nodesoup.hpp"}))
    end)
