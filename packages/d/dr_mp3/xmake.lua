package("dr_mp3")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/mackron/dr_libs")
    set_description("Single file audio decoding libraries for C/C++.")
    set_license("MIT")

    set_urls("https://github.com/mackron/dr_libs.git")
    add_versions("0.6.27", "f357ade3aae55ced341aa7c83b4e7f628f948e51")

    on_install(function (package)
        os.cp("dr_mp3.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("drmp3_init", {includes = "dr_mp3.h"}))
    end)
