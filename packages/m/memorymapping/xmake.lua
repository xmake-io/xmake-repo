package("memorymapping")

    set_homepage("https://github.com/NimbusKit/memorymapping")
    set_description("fmemopen port library")

    set_urls("https://github.com/NimbusKit/memorymapping.git")

    add_versions("2014.12.21", "79ce0ddd0de4b11e4944625eb866290368f867c0")

    on_install("macosx", "iphoneos", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("fmemopen")
                set_kind("$(kind)")
                add_files("src/*.c")
                add_headerfiles("src/*.h")
        ]])
        local configs = {}
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("fmemopen", {includes = {"stdio.h", "fmemopen.h"}}))
    end)
