set_xmakever("2.5.1")
set_languages("cxx14")

add_rules("mode.debug", "mode.release")

target("discordcpp")
    set_kind("static")

    add_includedirs("cpp")
    add_headerfiles("cpp/(*.h)")
    add_files("cpp/*.cpp")

