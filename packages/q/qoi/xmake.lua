package("qoi")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/phoboslab/qoi")
    set_description("The Quite OK Image Format for fast, lossless image compression")

    add_urls("https://github.com/phoboslab/qoi.git")
    add_versions("2021.12.22", "44fe081388c60e7618f49486865b992e08ce4de4")

    on_install(function (package)
        os.cp("qoi.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("qoi_encode", {includes = "qoi.h"}))
    end)
