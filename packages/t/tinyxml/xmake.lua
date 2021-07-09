package("tinyxml")

    set_homepage("https://sourceforge.net/projects/tinyxml/")
    set_description("TinyXML is a simple, small, minimal, C++ XML parser that can be easily integrating into other programs.")
    set_license("zlib")

    add_urls("https://jaist.dl.sourceforge.net/project/tinyxml/tinyxml/$(version).zip", {version = function (version) return version .. "/tinyxml_" .. version:gsub("%.", "_") end})
    add_versions("2.6.2", "ac6bb9501c6f50cc922d22f26b02fab168db47521be5e845b83d3451a3e1d512")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("tinyxml")
                set_kind("$(kind)")
                add_files("tinyxml.cpp", "tinystr.cpp", "tinyxmlerror.cpp", "tinyxmlparser.cpp")
                add_headerfiles("tinyxml.h", "tinystr.h")
        ]])
        local configs = {}
        if not package:is_plat("windows") and package:config("shared") then
            configs.kind = "shared"
        elseif package:is_plat("linux") and package:config("pic") ~= false then
            configs.cxflags = "-fPIC"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("TiXmlDocument", {includes = "tinyxml.h"}))
    end)
