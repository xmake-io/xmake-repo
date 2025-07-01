package("sheenbidi")
    set_homepage("https://github.com/Tehreer/SheenBidi")
    set_description("A sophisticated implementation of Unicode Bidirectional Algorithm")
    set_license("Apache-2.0")

    add_urls("https://github.com/Tehreer/SheenBidi/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Tehreer/SheenBidi.git")

    add_versions("v2.8", "6f27d5f347447f593bde573e4cb477925f7ed96afa4f936e7852803e1ddf3fea")
    add_versions("v2.7", "620f732141fd62354361f921a67ba932c44d94e73f127379a0c73ad40c7fa6e0")
    add_versions("v2.6", "f538f51a7861dd95fb9e3f4ad885f39204b5c670867019b5adb7c4b410c8e0d9")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c11")
            set_encodings("utf-8")

            target("sheenbidi")
                set_kind("$(kind)")
                add_files("Source/SheenBidi.c")
                add_defines("SB_CONFIG_UNITY")
                add_includedirs("Headers")
                add_headerfiles("Headers/*.h", {prefixdir = "SheenBidi"})
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
            ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SBAlgorithmCreate", {includes = "SheenBidi/SheenBidi.h", {configs = {languages = "c11"}}}))
    end)
