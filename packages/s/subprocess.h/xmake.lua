package("subprocess.h")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/sheredom/subprocess.h")
    set_description("single header process launching solution for C and C++ ")

    add_urls("https://github.com/sheredom/subprocess.h.git")
    add_versions("2022.12.20", "cf95c9615953c90177498aed43621cb1cbc8f3e1")

    on_install("windows", "macosx", "linux", "mingw", "bsd", function (package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("subprocess_create", {includes = "subprocess.h"}))
    end)
