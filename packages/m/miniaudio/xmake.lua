package("miniaudio")
    set_kind("library", {headeronly = true})
    set_homepage("https://miniaud.io")
    set_description("Single file audio playback and capture library written in C.")

    set_urls("https://github.com/mackron/miniaudio/archive/refs/tags/${version}.tar.gz",
             "https://github.com/mackron/miniaudio.git")
    add_versions("0.11.15", "26b0a9ffc0b2e9d0528106f2f5e4dfc90b0a0d6b")
    add_versions("0.11.16", "ea205fb7b0b63613f7586a4082ec9c42a0381920")
    add_versions("0.11.17", "d76b9a1ac424b5b259c2faeea0dc83d215df522a")


    on_install(function (package)
        os.cp("miniaudio.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ma_encoder_config_init", {includes = "miniaudio.h"}))
    end)
