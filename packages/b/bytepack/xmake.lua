package("bytepack")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/farukeryilmaz/bytepack")
    set_description("C++ Binary Serialization Made Easy: Header-only, configurable endianness, cross-platform, no IDL, no exceptions, and no macros")
    set_license("MIT")

    add_urls("https://github.com/farukeryilmaz/bytepack/archive/refs/tags/$(version).tar.gz",
             "https://github.com/farukeryilmaz/bytepack.git")

    add_versions("v0.1.0", "7761cf51736d4e1a65ca69323182930967846eaed04adddfd316f59a5c2eb244")

    on_check(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <algorithm>
            #include <string>
            void test() {
                std::string s{"xmake"};
                std::ranges::reverse(s.begin(), s.end());
            }
        ]]}, {configs = {languages = "c++20"}}), "package(bytepack) Require at least C++20.")
    end)

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <bytepack/bytepack.hpp>
            void test() {
                bytepack::binary_stream serializationStream(64);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
