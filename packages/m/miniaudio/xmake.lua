package("miniaudio")
    set_kind("library", {headeronly = true})
    set_homepage("https://miniaud.io")
    set_description("Single file audio playback and capture library written in C.")

    set_urls("https://github.com/mackron/miniaudio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mackron/miniaudio.git")
    add_versions("0.11.15", "24a6d38fe69cd42d91f6c1ad211bb559f6c89768c4671fa05b8027f5601d5457")
    add_versions("0.11.16", "13320464820491c61bd178b95818fecb7cd0e68f9677d61e1345df6be8d4d77e")
    add_versions("0.11.17", "4b139065f7068588b73d507d24e865060e942eb731f988ee5a8f1828155b9480")
    add_versions("0.11.18", "85ca916266d809b39902e180a6d16f82caea9c2ea1cea6d374413641b7ba48c3")

    if is_plat("iphoneos") then
        add_frameworks("AudioToolbox", "AVFoundation", "CoreFoundation", "Foundation")
    elseif is_plat("macosx") then
        add_defines("MA_NO_RUNTIME_LINKING")
        add_frameworks("AudioToolbox", "CoreAudio", "AudioUnit", "AVFoundation", "CoreFoundation", "Foundation")
    end

    on_install(function (package)
        os.cp("miniaudio.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ma_encoder_config_init", {includes = "miniaudio.h"}))
    end)
