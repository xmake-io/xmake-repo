package("boost_assert")
    set_kind("library", {headeronly = true})
    set_homepage("https://www.boost.org/libs/assert")
    set_description("Boost Assert Library")
    set_license("BSL-1.0")

    add_urls("https://github.com/boostorg/assert/archive/refs/tags/boost-$(version).tar.gz",
             "https://github.com/boostorg/assert.git")

    add_versions("1.91.0", "9145fba14048a46c0f65e5b28e68176d568148957ebf9bdf9e82bcc5d5a703a9")
    add_versions("1.90.0", "1f48f929e69146db222fdf9538ec81c7cbd3ca88b94343644942b477031a3bba")
    add_versions("1.89.0", "e25e42fbc5f77dcb203a3479eaf2e9303511f2a5bb8cbdf54e9c562fcbf29da1")

    add_deps("boost_config")

    on_install(function (package)
        os.cp("include/boost", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <boost/assert.hpp>
            void test() {
                BOOST_ASSERT(1 + 1 == 2);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
