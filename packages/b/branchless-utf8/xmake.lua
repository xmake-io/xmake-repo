package("branchless-utf8")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/skeeto/branchless-utf8")
    set_description("Branchless UTF-8 decoder")

    add_urls("https://github.com/skeeto/branchless-utf8.git")
    add_versions("2022.08.30", "e4d82fd5ddae98658f8c129006e3bc5acd0ae9f1")

    on_install(function (package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("utf8_decode", {includes = "utf8.h"}))
    end)
