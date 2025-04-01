add_rules("mode.debug", "mode.release")
set_languages("c++14")

target("simplewindow")
    set_kind("$(kind)")
    set_encodings("utf-8")
    add_includedirs("inc")
    add_headerfiles("inc/(*.h)", {prefixdir = "sw"})
    add_files("src/*.cpp")
