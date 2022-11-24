package("quickcpplib")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/ned14/quickcpplib")
    set_description("Eliminate all the tedious hassle when making state-of-the-art C++ 14 - 23 libraries!")
    set_license("Apache-2.0")

    add_urls("https://github.com/ned14/quickcpplib.git")
    add_versions("20221116", "52163d5a198f1d0a2583e683f090778686f9f998")

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <quickcpplib/uint128.hpp>
            void test () {
                auto bar = QUICKCPPLIB_NAMESPACE::integers128::uint128{};
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)

