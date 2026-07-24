package("boost_config")
    set_kind("library", {headeronly = true})
    set_homepage("https://www.boost.org/libs/config")
    set_description("Boost Config Library")
    set_license("BSL-1.0")

    add_urls("https://github.com/boostorg/config/archive/refs/tags/boost-$(version).tar.gz",
             "https://github.com/boostorg/config.git")

    add_versions("1.91.0", "e69618fa862927db69b4dd8e6b070c647a799b892fd0ee141d28db0dab025531")
    add_versions("1.90.0", "1390bd79fbf270e40cfe5ac6b899f4a9c4e47139b6e17b4c1f7f78822adaa9fc")
    add_versions("1.89.0", "a16a53f8f0dde2a9ff485fb134a069e54aca738009d825837dac9a35cd4afe0a")

    on_install(function (package)
        os.cp("include/boost", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <boost/config.hpp>
            int main()
            {
            #ifdef BOOST_MSVC
                std::cout << "Compiled with MSVC\n";
            #endif
            #ifdef BOOST_GCC
                std::cout << "Compiled with GCC\n";
            #endif
            #ifdef BOOST_CLANG
                std::cout << "Compiled with Clang\n";
            #endif
            #ifdef BOOST_WINDOWS
                std::cout << "Running on Windows\n";
            #endif
            #ifdef BOOST_LINUX
                std::cout << "Running on Linux\n";
            #endif
            #ifdef BOOST_NO_CXX17_IF_CONSTEXPR
                std::cout << "if constexpr is NOT supported\n";
            #else
                std::cout << "if constexpr is supported\n";
            #endif
                return 0;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
