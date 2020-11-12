package("jsoncons")

    set_homepage("https://danielaparker.github.io/jsoncons")
    set_description("A C++, header-only library for constructing JSON and JSON-like data formats, with JSON Pointer, JSON Patch, JSONPath, JMESPath, CSV, MessagePack, CBOR, BSON, UBJSON")

    set_urls("https://github.com/danielaparker/jsoncons/archive/$(version).zip",
             "https://github.com/danielaparker/jsoncons")

    add_versions("0.158.0", "7ad7cc0e9c74df495dd16b818758ec2e2a5b7fef8f1852841087fd5e8bb6a6cb")

    on_install(function (package)
        os.cp(path.join("include", "*"), package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <assert.h>
            using namespace jsoncons;
            std::string data = R"(
                {
                    "application": "hiking",
                    "reputons": [
                        {
                            "rater": "HikingAsylum",
                            "assertion": "advanced",
                            "rated": "Marilyn C",
                            "rating": 0.09,
                            "generated": 1514862245
                        }
                    ]
                }
            )";
            void test()
            {
                json j = json::parse(data);
                const std::string result = j["application"].as_string();
                assert(result == "hiking");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "jsoncons/json.hpp" }))
    end)
