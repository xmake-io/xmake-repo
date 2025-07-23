add_rules("mode.debug", "mode.release")

add_requires("expat", "libhubbub", "libparserutils", "libwapcaplet")
add_packages("expat", "libhubbub", "libparserutils", "libwapcaplet")

target("dom")
    set_kind("$(kind)")
    add_files("src/**.c", "bindings/hubbub/*.c", "bindings/xml/expat_xmlparser.c")
    add_includedirs("include", "src")
    add_headerfiles("include/(dom/**.h)")
    add_headerfiles("(bindings/**.h)", {prefixdir = "dom"})

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end
