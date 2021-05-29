package("dr_flac")
    set_homepage("https://github.com/mackron/dr_libs")
    set_description("Single file audio decoding libraries for C/C++.")
    set_license("MIT")

    set_urls("https://github.com/mackron/dr_libs.git")
    add_versions("0.12.29", "343aa923439e59e7a9f7726f70edc77a4500bdec")

    on_install(function (package)
        os.cp("dr_flac.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("drflac_open", {includes = "dr_flac.h"}))
    end)
