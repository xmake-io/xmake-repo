package("tinyformat")

    set_homepage("https://github.com/c42f/tinyformat/")
    set_description("Minimal, type safe printf replacement library for C++")
    
    add_urls("https://github.com/c42f/tinyformat/archive/v$(version).tar.gz")
    add_versions("2.3.0", "ecba2fbbd3829002a63e141b77b9f1fc30e920962f68466b50c3244652d69391")

    on_install(function (package)
        os.mv("tinyformat.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <string>
            void test() {
                tfm::printf("%s", "printf test");
                tfm::format(std::cout, "%s", "format test");
                std::string res = tfm::format("%s", "string format");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "tinyformat.h"}))
    end)
