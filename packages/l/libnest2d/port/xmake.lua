add_rules("mode.debug", "mode.release")

add_requires("nlopt", "polyclipping", "boost")

target("libnest2d")
    set_kind("$(kind)")
    set_languages("cxx14")
    add_packages("nlopt", "polyclipping", "boost")

    add_files("src/*.cpp")
    add_headerfiles("include/(**.hpp)")

    add_defines("LIBNEST2D_GEOMETRIES_clipper", "LIBNEST2D_OPTIMIZER_nlopt")

    add_includedirs("include", {public = true})

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end
