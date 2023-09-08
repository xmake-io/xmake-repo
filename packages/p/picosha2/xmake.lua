package("picosha2")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/okdshin/PicoSHA2")
    set_description("a header-file-only, SHA256 hash generator in C++")
    set_license("MIT")

    add_urls("https://github.com/okdshin/PicoSHA2.git")
    add_versions("2022.08.08", "27fcf6979298949e8a462e16d09a0351c18fcaf2")

    on_install(function (package)
        os.cp("picosha2.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <picosha2.h>
            void test() {
                picosha2::hash256_one_by_one hasher;
            }
        ]]}))
    end)
