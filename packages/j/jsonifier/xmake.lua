package("jsonifier")
    set_homepage("https://github.com/RealTimeChris/Jsonifier")
    set_description("A few classes for parsing and serializing objects from/into JSON, in C++ - very rapidly.")
    set_license("MIT")

    add_urls("https://github.com/RealTimeChris/Jsonifier.git")
    add_versions("2023.12.27", "b4aa08dcb900f8e097f701c15526cfb891425b9d")

    add_deps("cmake")

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
