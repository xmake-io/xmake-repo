package("audiofile")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/adamstark/AudioFile")
    set_description("A simple C++ library for reading and writing audio files.")
    set_license("MIT")

    add_urls("https://github.com/adamstark/AudioFile/archive/refs/tags/$(version).tar.gz",
             "https://github.com/adamstark/AudioFile.git")

    add_versions("1.1.4", "e3749f90a9356b5206ef8928fa0a9c039e7db49e46bb7f32c3963d6c44c5bea8")
    add_versions("1.1.3", "abc22bbe798cb552048485ce19278f35f587340bf0d5c68ac0028505eaf70dfe")
    add_versions("1.1.2", "d090282207421e27be57c3df1199a9893e0321ea7c971585361a3fc862bb8c16")
    add_versions("1.1.1", "664f9d5fbbf1ff6c603ae054a35224f12e9856a1d8680be567909015ccaac328")
    add_versions("1.1.0", "7546e39ca17ac09c653f46bfecce4a9936fae3784209ad53094915c78792a327")
    add_versions("1.0.9", "1d609b80496fc5c688d8e83086cdcad5b60ddb20f02d160f80be271fab97c4c0")
    add_versions("1.0.8", "f9ecc578425cb90a4a846b32c8ac162c9a61952713bd07525337245a8dee8ad2")
    add_versions("1.0.7", "a03c8dfee26e34e96ca07065b72a9a6860cf9a78849abf26c32a4db42469f6e6")
    add_versions("1.0.6", "ac802070beb217c373a0fba83d3e7542672cf8118763677bb8c5de396030cf40")
    add_versions("1.0.5", "61b7328459591aa11edfee7377acffa3c5638bac71a0fa57ddafe95b696eeed1")
    add_versions("1.0.4", "cb57df92f252d194b911eebe6dedaba2c063a02c2579e00bf0a18cac92793027")
    add_versions("1.0.3", "7c5d2b89b2c8675faee36de63ddcb5df3f9e1514439c2578e462b8ab2950571d")
    add_versions("1.0.2", "63b7f0b76318299be7f74944f50967825240124aab3c0f82f1753689c2c5a092")
    add_versions("1.0.1", "c52957662b717addd32b6c72b279d0c82fb5cf0fe74f98fa74469ae6bcba5b26")
    add_versions("1.0.0", "2740f8b7b5f70f6ac848e3e2814ceeae141d806c07424a0cd03fde2ecaf463f1")

    on_install(function (package)
        os.cp("AudioFile.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <stdint.h>
            #include <AudioFile.h>

            void test () {
                AudioFile<float> audioFile;
                audioFile.load("somerandomfile.wav");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
