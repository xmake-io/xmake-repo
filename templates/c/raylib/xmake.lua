add_rules("mode.debug", "mode.release")

add_requires("raylib")

target("${TARGET_NAME}")
    set_kind("binary")
    add_files("src/*.c")
    add_packages("raylib")
    set_languages("c99")

${FAQ}
