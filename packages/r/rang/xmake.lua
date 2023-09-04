package("rang")
    set_kind("library", {headeronly = true})
    set_homepage("https://agauniyal.github.io/rang/")
    set_description("A Minimal, Header only Modern c++ library for terminal goodies 💄✨")
    set_license("Unlicense")

    add_urls("https://github.com/agauniyal/rang.git")
    add_versions("2022.07.01", "22345aa4c468db3bd4a0e64a47722aad3518cc81")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <rang.hpp>
            void test() {
                std::cout << "Plain old text" << rang::style::bold;
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
