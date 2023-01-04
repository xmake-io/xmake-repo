package("json.h")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/sheredom/json.h")
    set_description("single header json parser for C and C++")

    add_urls("https://github.com/sheredom/json.h.git")
    add_versions("2022.11.27", "06aa5782d650e7b46c6444c2d0a048c0a1b3a072")

    on_install(function (package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("json_parse", {includes = "json.h"}))
    end)
