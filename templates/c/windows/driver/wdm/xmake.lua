add_rules("mode.debug", "mode.release")

target("${TARGET_NAME}")
    add_rules("wdk.driver", "wdk.env.wdm")
    add_files("src/*.c")
    add_files("src/*.inf")

${FAQ}
