package("bin2c")

    set_homepage("https://github.com/gwilymk/bin2c")
    set_description("A simple utility for converting a binary file to a c application")

    set_kind("binary")
    set_urls("https://github.com/gwilymk/bin2c.git")

    add_versions("0.0.1", "598395c23508bd4a2c916bfdab8c04a101abc62e")
    add_patches("0.0.1", path.join(os.scriptdir(), "patches", "0.0.1", "bin2c-test.patch"), "e3c8b80948dba824d8ffa0c3294f9b32ca3001c77a80b45f02a46a1e8586a7e1")

    on_install(function (package)
        io.writefile("xmake.lua", [[
        add_rules("mode.debug", "mode.release")
        target("bin2c")
            set_kind("binary")
            add_files("bin2c.c")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        os.vrun("bin2c test") 
    end)
