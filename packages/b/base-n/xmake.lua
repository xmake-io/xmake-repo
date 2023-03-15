package("base-n")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/azawadzki/base-n")
    set_description("A small, single-header library which provides standard Base16, Base32, Base64, and custom Base-N encoding support.")
    set_license("MIT")

    add_urls("https://github.com/azawadzki/base-n.git")
    add_versions("2020.05.28", "7573e77c0b9b0e8a5fb63d96dbde212c921993b4")

    on_install(function (package)
        os.cp("include/basen.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <string>
            #include <iostream>
            #include <basen.hpp>
            
            void test () {
                std::string in = "test";
                std::string encoded;
                bn::encode_b64(in.begin(), in.end(), back_inserter(encoded));
                std::cout << encoded << std::endl; 
            }
        ]]}, {configs = {languages = "c++11"}, includes = "basen.hpp"}))
    end)
