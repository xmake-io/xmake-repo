package("dirent")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/tronkko/dirent")
    set_description("C/C++ library for retrieving information on files and directories")
    set_license("MIT")

    add_urls("https://github.com/tronkko/dirent/archive/refs/tags/$(version).tar.gz",
             "https://github.com/tronkko/dirent.git")

    add_versions("1.24", "37009127a65bb1ddc47d06c097321f87f45ca2e998b2ec3bf2e0b2b19649d6f9")

    on_install("windows", "mingw", "msys", "cygwin", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cfuncs("opendir", {includes = "dirent.h"}))
    end)
