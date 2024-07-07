add_rules("mode.debug", "mode.release")

target("macdylibbundler")
    set_kind("$(kind)")
    set_languages("c++11")
    add_files("src/*.cpp")
    add_includedirs("src")

    add_headerfiles("src/*.h")

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end
