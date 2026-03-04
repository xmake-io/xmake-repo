add_rules("mode.debug", "mode.release")

target("${TARGET_NAME}")
    add_rules("wdk.driver", "wdk.env.umdf")
    add_values("wdk.env.umdf.ver", "2")
    add_files("src/*.c")
    add_files("src/*.inf")

${FAQ}
