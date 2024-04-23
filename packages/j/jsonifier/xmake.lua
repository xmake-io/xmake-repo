package("jsonifier")
    set_homepage("https://github.com/RealTimeChris/Jsonifier")
    set_description("A few classes for parsing and serializing objects from/into JSON, in C++ - very rapidly.")
    set_license("MIT")

    add_urls("https://github.com/RealTimeChris/Jsonifier/archive/refs/tags/$(version).tar.gz",
             "https://github.com/RealTimeChris/Jsonifier.git")
    
    add_versions("v0.9.95", "65604a378e703079d041dfeae77726ddf745e949d34e67d9adea5dc35d8df219")

    on_install(function (package)
        os.cp("Include/jsonifier", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <jsonifier/Index.hpp>
            void test() {
                jsonifier::jsonifier_core parser{};
                std::string buffer = "{\"key\": \"value\"}";
                parser.validate(buffer);
            }
        ]]}, {configs = {languages = "cxx20"}}))
    end)
