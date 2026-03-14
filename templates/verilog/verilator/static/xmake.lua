add_rules("mode.debug", "mode.release")

add_requires("verilator")

target("${TARGET_NAME}")
    add_rules("verilator.static")
    set_toolchains("@verilator")
    add_files("src/*.v")

target("test")
    add_deps("${TARGET_NAME}")
    add_files("src/*.cpp")

${FAQ}
