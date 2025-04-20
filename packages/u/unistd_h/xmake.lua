package("unistd_h")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/win32ports/unistd_h")
    set_description("header-only Windows implementation of the <unistd.h> header")
    set_license("MIT")

    add_urls("https://github.com/win32ports/unistd_h.git")
    add_versions("2019.07.30", "0dfc48c1bc67fa27b02478eefe0443b8d2750cc2")

    on_install("windows", "mingw", function (package)
        os.cp("unistd.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("access", {includes = "unistd.h"}))
    end)
