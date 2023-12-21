package("utf8.h")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/sheredom/utf8.h")
    set_description("single header utf8 string functions for C and C++")

    add_urls("https://github.com/sheredom/utf8.h.git")
    add_versions("2022.07.04", "4e4d828174c35e4564c31a9e35580c299c69a063")

    on_install(function (package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("utf8casecmp", {includes = "utf8.h"}))
    end)
