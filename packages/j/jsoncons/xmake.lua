package("jsoncons")

    set_kind("library", {headeronly = true})
    set_homepage("https://danielaparker.github.io/jsoncons/")
    set_description("A C++, header-only library for constructing JSON and JSON-like data formats, with JSON Pointer, JSON Patch, JSONPath, JMESPath, CSV, MessagePack, CBOR, BSON, UBJSON")

    set_urls("https://github.com/danielaparker/jsoncons/archive/$(version).zip",
             "https://github.com/danielaparker/jsoncons.git")

    add_versions("v0.158.0", "7ad7cc0e9c74df495dd16b818758ec2e2a5b7fef8f1852841087fd5e8bb6a6cb")
    add_versions("v0.170.2", "81ac768eecb8cf2613a09a9d081294895d7afd294b841166b4e1378f0acfdd6e")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <string>
            using namespace jsoncons;
            std::string data = R"(
                            {
                                "application": "hiking",
                                "reputons":
                                [
                                    {
                                        "rater": "HikingAsylum",
                                        "assertion": "advanced",
                                        "rated": "Marilyn C",
                                        "rating": 0.90,
                                        "generated": 1514862245
                                    }
                                ]
                            }
                        )";
            void test() {
                json j = json::parse(data);
                std::cout << "(1) " << std::boolalpha << j.contains("reputons") << "\n\n";
                const json &v = j["reputons"];
                for (const auto &item : v.array_range()) {
                    // Access rated as string and rating as double
                    std::cout << item["rated"].as<std::string>() << ", "
                            << item["rating"].as<double>() << "\n";
                }
                std::cout << "\n";
                std::cout << "(3)\n";
                json result = jsonpath::json_query(j, "$..rated");
                std::cout << pretty_print(result) << "\n\n";
                std::cout << "(4)\n" << pretty_print(j) << "\n\n";
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"jsoncons/json.hpp", "jsoncons_ext/jsonpath/jsonpath.hpp"}}))
    end)
