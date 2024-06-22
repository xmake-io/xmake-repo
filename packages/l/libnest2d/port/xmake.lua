add_rules("mode.debug", "mode.release")

add_requires("nlopt", "polyclipping", "boost_geometry")

target("libnest2d")
    set_kind("$(kind)")
    set_languages("cxx11")
    add_packages("nlopt", "polyclipping", "boost_geometry")

    add_files("src/*.cpp")
    add_headerfiles("include/(**.hpp)")

    add_defines("LIBNEST2D_GEOMETRIES_clipper", "LIBNEST2D_OPTIMIZER_nlopt")

    add_includedirs("include", {public = true})
