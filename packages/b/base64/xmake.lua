package("base64")
    set_kind("library", {headeronly = true})
    set_homepage("https://terrakuh.github.io/base64/classbase64.html")
    set_description("Simple, open source, header-only base64 encoder")
    set_license("Unlicense")

    add_urls("https://github.com/terrakuh/base64/archive/refs/tags/$(version).tar.gz",
             "https://github.com/terrakuh/base64.git")

    add_versions("v1.0", "91bb16e7fc4571d6967bf85dc1c3c29679eade52c91b5d022f26f346ac8b592d")

    on_install(function (package)
        os.cp("base64.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <base64.hpp>
            void test() {
                std::string encoded = base64::encode("hello, world");
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
