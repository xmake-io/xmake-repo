add_rules("mode.debug", "mode.release")

add_requires("minizip-ng")
add_packages("minizip-ng")

target("11zip")
    set_kind("$(kind)")
    set_languages("c++17")
    add_files("src/*.cpp")
    remove_files("src/elzip_fs_fallback.cpp")
    add_includedirs("include", "include/elzip")

    add_headerfiles("include/(**.hpp)")

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end
