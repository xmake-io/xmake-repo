package("sheenbidi")
    set_homepage("https://github.com/Tehreer/SheenBidi")
    set_description("A sophisticated implementation of Unicode Bidirectional Algorithm")
    set_license("Apache-2.0")

    add_urls("https://github.com/Tehreer/SheenBidi/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Tehreer/SheenBidi.git")

    add_versions("v2.6", "f538f51a7861dd95fb9e3f4ad885f39204b5c670867019b5adb7c4b410c8e0d9")

    add_deps("meson", "ninja")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SBAlgorithmCreate", {includes = "SheenBidi/SheenBidi.h", {configs = {languages = "c11"}}}))
    end)
