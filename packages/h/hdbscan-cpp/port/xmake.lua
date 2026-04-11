add_rules("mode.release", "mode.debug")

target("hdbscan-cpp")
do
    set_kind("$(kind)")
    set_languages("cxx11")
    add_includedirs("HDBSCAN-CPP")
    add_headerfiles("HDBSCAN-CPP/(**/*.hpp)")
    add_files("HDBSCAN-CPP/**/*.cpp")
end