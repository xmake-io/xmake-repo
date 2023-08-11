package("sheenbidi")
    set_homepage("https://github.com/Tehreer/SheenBidi")
    set_description("A sophisticated implementation of Unicode Bidirectional Algorithm")
    set_license("Apache-2.0")

    add_urls("https://github.com/Tehreer/SheenBidi/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Tehreer/SheenBidi.git")

    add_versions("v2.6", "f538f51a7861dd95fb9e3f4ad885f39204b5c670867019b5adb7c4b410c8e0d9")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c11")
            target("raqm")
                set_kind("$(kind)")
                add_files("Source/SheenBidi.c")
                add_defines("SB_CONFIG_UNITY")
                add_includedirs("Headers")
                add_headerfiles("Headers/*.h", {prefixdir = "SheenBidi"})
        ]])
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SBAlgorithmCreate", {includes = "SheenBidi/SheenBidi.h", {configs = {languages = "c11"}}}))
    end)
