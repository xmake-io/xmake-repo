package("pl_mpeg")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/phoboslab/pl_mpeg")
    set_description("Single file C library for decoding MPEG1 Video and MP2 Audio")
    set_license("MIT")

    set_urls("https://github.com/phoboslab/pl_mpeg.git")
    add_versions("2024.04.12", "9e40dd6536269d788728e32c39bfacf2ab7a0866")

    on_install(function (package)
        os.cp("pl_mpeg.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("plm_create_with_filename", {includes = "pl_mpeg.h"}))
    end)