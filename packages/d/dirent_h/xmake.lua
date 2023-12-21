package("dirent_h")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/win32ports/dirent_h")
    set_description("header-only Windows implementation of the <dirent.h> header")
    set_license("MIT")

    add_urls("https://github.com/win32ports/dirent_h.git")
    add_versions("2021.09.25", "0170b775ae7cede136c0c1f71b8e5002cc36288b")

    on_install("windows", function (package)
        os.cp("dirent.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("opendir", {includes = "dirent.h"}))
    end)
