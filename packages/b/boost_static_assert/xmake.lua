package("boost_static_assert")
    set_kind("library", {headeronly = true})
    set_homepage("https://www.boost.org/libs/static_assert")
    set_description("Boost StaticAssert Library")
    set_license("BSL-1.0")

    add_urls("https://github.com/boostorg/static_assert/archive/refs/tags/boost-$(version).tar.gz",
             "https://github.com/boostorg/static_assert.git")

    add_versions("1.91.0", "23217831b80926140ac0cfb62d0cde5b8c878cf5b568852b2f3c6366fdb75820")
    add_versions("1.90.0", "3b7980c5968d585b04f980bbb4e81bbbf0b6d1a0b7c965c2a3426b0acb4a5f49")
    add_versions("1.89.0", "48ef5ced01a5a4a0b940eb23eb5a0d5a54c8f27ca7326f86a2b90be405f5d53f")

    add_deps("boost_config")

    on_install(function (package)
        os.cp("include/boost", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <boost/static_assert.hpp>
            BOOST_STATIC_ASSERT(sizeof(int) >= 2);
            void test() {}
        ]]}, {configs = {languages = "c++17"}}))
    end)
