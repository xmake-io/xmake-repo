add_rules("mode.debug", "mode.release")

target("wapcaplet")
    set_kind("$(kind)")
    add_files("src/*.c")
    add_includedirs("include")
    add_headerfiles("include/(libwapcaplet/*.h)")

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end
