add_rules("mode.debug", "mode.release")

option("openmp", {default = false, showmenu = true, description = "Enable OpenMP"})

if has_config("openmp") then
    add_requires("openmp", {configs = { feature = "llvm" }})
end

add_requires("armadillo", "cereal", "ensmallen", "stb")

target("mlpack")
    set_kind("headeronly")
    set_languages("cxx17")
    add_options("openmp")

    add_packages("armadillo", "cereal", "ensmallen", "stb")

    if has_config("openmp") then
        add_packages("openmp")
    end

    add_headerfiles("src/(mlpack.hpp)")
    add_headerfiles("src/(mlpack/*.hpp)")
    add_headerfiles("src/(mlpack/core/**.hpp)", "src/(mlpack/methods/**.hpp)")
