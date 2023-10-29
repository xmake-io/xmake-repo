package("cthash")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/hanickadot/cthash")
    set_description("constexpr implementation of SHA-2 and SHA-3 family of hashes")
    set_license("Apache-2.0")

    add_urls("https://github.com/hanickadot/cthash.git")
    add_versions("2023.10.24", "21d581e0a6bd7040c282af1e43faab9d44f47744")

    on_install("linux", "macosx", "bsd", "mingw", "msys", "android", "iphoneos", "cross", "wasm", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cthash/cthash.hpp>
            using namespace cthash::literals;
            void test() {
                constexpr auto my_hash = cthash::simple<cthash::sha3_256>("hello there!");
                static_assert(my_hash == "c7fd85f649fba4bd6fb605038ae8530cf2239152bbbcb9d91d260cc2a90a9fea"_sha3_256);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
