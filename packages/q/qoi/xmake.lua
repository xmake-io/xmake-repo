package("qoi")

    set_kind("library", {headeronly = true})
    set_homepage("https://qoiformat.org/")
    set_description("The Quite OK Image Format for fast, lossless image compression")
    set_license("MIT")

    add_urls("https://github.com/phoboslab/qoi.git")
    add_versions("2021.12.22", "44fe081388c60e7618f49486865b992e08ce4de4")
    add_versions("2022.11.17", "660839cb2c51d6b5f62221f8ef98662fd40e42d2")

    on_install(function (package)
        os.cp("qoi.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("qoi_encode", {includes = "qoi.h"}))
    end)
