package("miniaudio")
    set_kind("library", {headeronly = true})
    set_homepage("https://miniaud.io")
    set_description("Single file audio playback and capture library written in C.")

    add_urls("https://github.com/mackron/miniaudio.git")
    add_versions("2021.12.31", "42abbbea4602af80d1ccb4a22cdc35813aceee7a")

    on_install(function (package)
        os.cp("miniaudio.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ma_encoder_config_init", {includes = "miniaudio.h"}))
    end)
