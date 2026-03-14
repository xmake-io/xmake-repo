add_rules("mode.debug", "mode.release")

add_requires("python 3.x")

target("${TARGET_NAME}")
    add_rules("swig.cpp", {moduletype = "python"})
    add_files("src/example.i", {scriptdir = "share"})
    add_files("src/example.cpp")
    add_packages("python")

${FAQ}
