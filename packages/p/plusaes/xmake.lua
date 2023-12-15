package("plusaes")
    set_kind("library", {headeronly = true})
    set_homepage("https://kkayataka.github.io/plusaes/doc/index.html")
    set_description("Header only C++ AES cipher library")
    set_license("BSL-1.0")

    add_urls("https://github.com/kkAyataka/plusaes/archive/refs/tags/$(version).tar.gz",
             "https://github.com/kkAyataka/plusaes.git")

    add_versions("v1.0.0", "0e33e8d0e2ea5e6f9eb7a06093f576350ce8ef58339ce9de791514a8f433087d")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vector>
            #include <plusaes/plusaes.hpp>
            void test() {
                const std::vector<unsigned char> key = plusaes::key_from_string(&"EncryptionKey128");
            }
        ]]}))
    end)
