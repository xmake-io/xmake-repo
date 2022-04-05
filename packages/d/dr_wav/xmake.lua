package("dr_wav")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/mackron/dr_libs")
    set_description("Single file audio decoding libraries for C/C++.")
    set_license("MIT")

    set_urls("https://github.com/mackron/dr_libs.git")
    add_versions("0.12.19", "46f149034a9f27e873d2c4c6e6a34ae4823a2d8d")

    on_install(function (package)
        os.cp("dr_wav.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("drwav_init_ex", {includes = "dr_wav.h"}))
    end)
