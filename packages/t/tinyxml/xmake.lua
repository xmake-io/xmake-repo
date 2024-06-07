package("tinyxml")

    set_homepage("https://sourceforge.net/projects/tinyxml/")
    set_description("TinyXML is a simple, small, minimal, C++ XML parser that can be easily integrating into other programs.")
    set_license("zlib")

    add_urls("https://sourceforge.net/projects/tinyxml/files/tinyxml/$(version).zip", {version = function (version) return version .. "/tinyxml_" .. version:gsub("%.", "_") end})
    add_versions("2.6.2", "ac6bb9501c6f50cc922d22f26b02fab168db47521be5e845b83d3451a3e1d512")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end
    add_configs("stl", {description = "Enable STL support.", default = true, type = "boolean"})

    on_install(function (package)
        if package:config("stl") then
            io.replace("tinyxml.h", "#define TINYXML_INCLUDED", "#define TINYXML_INCLUDED\n#define TIXML_USE_STL", {plain = true})
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("tinyxml")
                set_kind("$(kind)")
                add_files("tinyxml.cpp", "tinystr.cpp", "tinyxmlerror.cpp", "tinyxmlparser.cpp")
                add_headerfiles("tinyxml.h", "tinystr.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("TiXmlDocument", {includes = "tinyxml.h"}))
    end)
