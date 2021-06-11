package("minimp3")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/lieff/minimp3")
    set_description("Minimalistic MP3 decoder single header library")
    set_license("CC0")

    set_urls("https://github.com/lieff/minimp3.git")
    add_versions("2021.05.29", "b18d274b998cd4406070ddc1f370f53392241af0")

    on_install(function (package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                mp3dec_t dec;
                mp3dec_init(&dec);
            }
        ]]}, {includes = {"minimp3.h"}}))
    end)
