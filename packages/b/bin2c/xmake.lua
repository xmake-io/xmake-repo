package("bin2c")

    set_homepage("https://github.com/gwilymk/bin2c")
    set_description("A simple utility for converting a binary file to a c application")

    set_kind("binary")
    set_urls("https://github.com/gwilymk/bin2c.git")

    add_versions("0.0.1", "598395c23508bd4a2c916bfdab8c04a101abc62e")
    add_patches("0.0.1", path.join(os.scriptdir(), "patches", "0.0.1", "bin2c-test.patch"), "e3c8b80948dba824d8ffa0c3294f9b32ca3001c77a80b45f02a46a1e8586a7e1")

    on_install("@linux", "@macosx", function (package)
        os.vrun("make bin2c")
        os.cp("bin2c", package:installdir("bin"))
    end)

    on_install("@windows", function (package)
        import("lib.detect.find_tool")
        import("core.tool.toolchain")
        local runenvs = toolchain.load("msvc"):runenvs()
        local compiler = find_tool("cl", {envs = runenvs})
        os.vrunv(compiler.program, {"bin2c.c"}, {envs = runenvs})
        os.cp("bin2c.exe", package:installdir("bin"))
    end)

    on_install("mingw@windows", function (package)
        import("lib.detect.find_tool")
        local compiler = find_tool("gcc")
        os.vrunv(compiler.program, {"-obin2c.exe", "bin2c.c"})
        os.cp("bin2c.exe", package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrun("bin2c test") 
    end)
