add_rules("mode.debug", "mode.release")

add_requires("verilator")

target("${TARGET_NAME}")
    add_rules("verilator.binary")
    set_toolchains("@verilator")
    add_files("src/*.v")
    add_files("src/*.cpp")

${FAQ}
