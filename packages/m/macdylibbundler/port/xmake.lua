add_rules("mode.debug", "mode.release")

target("macdylibbundler")
    set_kind("$(kind)")
    set_languages("c++11")
    add_files("src/*.cpp")
    add_includedirs("src")

    add_headerfiles("src/*.h")
