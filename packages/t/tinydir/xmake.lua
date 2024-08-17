package("tinydir")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/cxong/tinydir")
    set_description("Lightweight, portable and easy to integrate C directory and file reader")

    add_urls("https://github.com/cxong/tinydir/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cxong/tinydir.git")

    add_versions("1.2.6", "1ecbdf8d04b079f8a9404662708d2333d6b72b956effb0d5296d063db3a02b4e")

    on_install(function (package)
        os.cp("tinydir.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("tinydir_open", {includes = "tinydir.h"}))
    end)
