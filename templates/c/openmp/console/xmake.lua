add_rules("mode.debug", "mode.release")

add_requires("openmp")

target("${TARGET_NAME}")
    set_kind("binary")
    add_files("src/*.c")
    add_packages("openmp")

${FAQ}
