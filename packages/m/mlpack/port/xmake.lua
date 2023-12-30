add_rules("mode.debug", "mode.release")

add_requires("armadillo", "cereal", "ensmallen", "stb")

target("mlpack")
    set_kind("headeronly")
    set_languages("cxx17")

    add_packages("armadillo", "cereal", "ensmallen", "stb")

    add_headerfiles("src/(mlpack.hpp)")
    add_headerfiles("src/(mlpack/*.hpp)")
    add_headerfiles("src/(mlpack/core/**.hpp)", "src/(mlpack/methods/**.hpp)")
