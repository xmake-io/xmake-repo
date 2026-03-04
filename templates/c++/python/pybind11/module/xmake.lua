add_rules("mode.debug", "mode.release")

add_requires("pybind11")

target("${TARGET_NAME}")
    add_rules("python.module", {soabi = false})
    add_files("src/*.cpp")
    add_packages("pybind11")
    set_languages("c++11")

${FAQ}
