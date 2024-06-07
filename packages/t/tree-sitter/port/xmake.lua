add_rules("mode.debug", "mode.release")
target("tree-sitter")
    set_kind("$(kind)")
    add_files("lib/src/lib.c")
    add_includedirs({
        "lib/src",
        "lib/include"})
    add_headerfiles("lib/include/(**.h)")