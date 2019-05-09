package("cjson")

    set_homepage("https://github.com/DaveGamble/cJSON")
    set_description("Ultralightweight JSON parser in ANSI C.")

    set_urls("https://github.com/DaveGamble/cJSON/archive/v$(version).zip",
             "https://github.com/DaveGamble/cJSON.git")
    add_versions("1.7.10", "80a0584410656c8d8da2ba703744f44d7535fc4f0778d8bf4f980ce77c6a9f65")

    on_install("macosx", "linux", "iphoneos", "android", function (package)
        import("package.tools.make").build(package, {"static"})
        os.cp("*.a", package:installdir("lib"))
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cJSON_malloc", {includes = "cJSON.h"}))
    end)
