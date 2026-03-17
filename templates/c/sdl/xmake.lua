add_rules("mode.debug", "mode.release")

add_requires("libsdl2")

target("${TARGET_NAME}")
    set_kind("binary")
    add_files("src/*.c")
    add_packages("libsdl2")
    set_languages("c99")

${FAQ}
