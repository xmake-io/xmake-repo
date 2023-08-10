package("dirent")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/tronkko/dirent")
    set_description("C/C++ library for retrieving information on files and directories")
    set_license("MIT")

    add_urls("https://github.com/tronkko/dirent.git")
    add_versions("2023.5.21", "ab35ddf7611b19529e0d7ef7e9719429483dcddd")

    on_install("windows", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cfuncs("opendir", {includes = "dirent.h"}))
    end)
