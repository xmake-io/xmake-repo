package("alsa-lib")
    set_homepage("https://alsa-project.org/wiki/Main_Page")
    set_description("The Advanced Linux Sound Architecture (ALSA) provides audio and MIDI functionality to the Linux operating system.")

    set_urls("http://www.alsa-project.org/files/pub/lib/alsa-lib-$(version).tar.bz2")

    add_versions("1.2.10", "c86a45a846331b1b0aa6e6be100be2a7aef92efd405cf6bac7eef8174baa920e")

    on_install("linux", function (package)
        local configs = {"--without-versioned"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                snd_ctl_card_info_t *info;
                snd_ctl_card_info_alloca(&info);
            }
        ]]}, {includes = {"alsa/asoundlib.h"}}))
    end)
