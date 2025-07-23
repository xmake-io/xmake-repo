package("jsmn")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/zserge/jsmn")
    set_description("Jsmn is a world fastest JSON parser/tokenizer")
    set_license("MIT")

    set_urls("https://github.com/zserge/jsmn/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zserge/jsmn.git")

    add_versions("v1.1.0", "5f0913a10657fe7ec8d5794ccf00a01000e3e1f2f1e1f143c34a0f7b47edcb38")

    on_install(function (package)
        os.cp("jsmn.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("jsmn_parse", {includes = "jsmn.h"}))
    end)

