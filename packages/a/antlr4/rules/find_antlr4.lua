-- https://github.com/antlr/antlr4/blob/master/runtime/Cpp/cmake/antlr4-generator.cmake.in
rule("find_antlr4")
    on_config(function(target)
        import("lib.detect.find_tool")

        assert(target:pkg("antlr4"), "Please configure add_packages(\"antlr4\") for target(" .. target:name() .. ")")
        
        local envs = target:pkgenvs()
        local java = assert(find_tool("java", {envs = envs}), "java not found!")
        local argv = {
            "-classpath",
            envs.CLASSPATH,
            "org.antlr.v4.Tool",
            "-Dlanguage=Cpp",
        }

        target:data_set("antlr4.tool", java)
        target:data_set("antlr4.tool.argv", argv)
    end)
