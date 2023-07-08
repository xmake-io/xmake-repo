package("dr_mp3")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/mackron/dr_libs")
    set_description("Single file audio decoding libraries for C/C++.")
    set_license("MIT")

    set_urls("https://github.com/mackron/dr_libs.git")
    add_versions("0.6.37", "1b0bc87c6b9b04052e6ef0117396dab8482c250e")
    add_versions("0.6.36", "b7f4c04e77b4c14347b74503e4ce93494e314283")
    add_versions("0.6.34", "dd762b861ecadf5ddd5fb03e9ca1db6707b54fbb")
    add_versions("0.6.27", "f357ade3aae55ced341aa7c83b4e7f628f948e51")

    on_install(function (package)
        os.cp("dr_mp3.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("drmp3_init", {includes = "dr_mp3.h"}))
    end)
