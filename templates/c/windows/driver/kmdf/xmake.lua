add_rules("mode.debug", "mode.release")

target("${TARGET_NAME}")
    add_rules("wdk.driver", "wdk.env.kmdf")
    add_values("wdk.env.kmdf.ver", "1.15")
    add_files("src/*.c")
    add_files("src/*.inf")

${FAQ}
