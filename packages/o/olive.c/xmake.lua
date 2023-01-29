package("olive.c")
    set_kind("library", {headeronly = true})
    set_homepage("https://tsoding.github.io/olive.c/")
    set_description("Simple 2D Graphics Library for C")
    set_license("MIT")

    add_urls("https://github.com/tsoding/olive.c.git")
    add_versions("2022.12.14", "95af28b808a243098fe7866e8035b24c3fe28ea1")

    on_install(function (package)
        os.cp("olive.c", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("olivec_fill", {includes = "olive.c",
            configs = {defines = "OLIVEC_IMPLEMENTATION"}}))
    end)
