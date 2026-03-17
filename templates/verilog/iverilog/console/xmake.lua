add_rules("mode.debug", "mode.release")

add_requires("iverilog")

target("${TARGET_NAME}")
    add_rules("iverilog.binary")
    set_toolchains("@iverilog")
    add_files("src/*.v")

${FAQ}
