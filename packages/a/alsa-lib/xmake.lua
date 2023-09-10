package("alsa-lib")
    set_homepage("https://alsa-project.org/wiki/Main_Page")
    set_description("The Advanced Linux Sound Architecture (ALSA) provides audio and MIDI functionality to the Linux operating system.")

    set_urls("http://www.alsa-project.org/files/pub/lib/alsa-lib-$(version).tar.bz2")

    add_versions("1.2.10", "c86a45a846331b1b0aa6e6be100be2a7aef92efd405cf6bac7eef8174baa920e")

    on_install("linux", function (package)
        local configs = {}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("snd_ctl_card_info_alloca", {includes = "alsa/asoundlib.h"}))
    end)

