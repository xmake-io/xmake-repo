add_rules("mode.debug", "mode.release")

target("${TARGET_NAME}")
    add_rules("platform.linux.driver")
    add_files("src/*.c")
    set_license("GPL-2.0")

${FAQ}
