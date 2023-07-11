package("fxdiv")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Maratyszcza/FXdiv")
    set_description("C99/C++ header-only library for division via fixed-point multiplication by inverse")
    set_license("MIT")

    add_urls("https://github.com/Maratyszcza/FXdiv.git")
    add_versions("2020.12.09", "63058eff77e11aa15bf531df5dd34395ec3017c8")

    on_install("windows", "macosx", "linux", function(package)
        os.cp("include", package:installdir())
    end)

    on_test(function(package)
        assert(package:has_cfuncs("fxdiv_init_uint32_t", {includes = "fxdiv.h"}))
    end)
