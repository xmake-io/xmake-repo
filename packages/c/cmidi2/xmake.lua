package("cmidi2")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/atsushieno/cmidi2")
    set_description("header-only MIDI 2.0 UMP and MIDI-CI binary processor library")
    set_license("MIT")

    add_urls("https://github.com/atsushieno/cmidi2.git")
    add_versions("2023.08.07", "8c7e2c218bb522bba6eabc6f55a6676e4a77138c")

    on_install(function (package)
        os.cp("cmidi2.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cmidi2_ump_get_num_bytes", {includes = "cmidi2.h"}))
    end)
