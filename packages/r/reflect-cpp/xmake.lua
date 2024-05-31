package("reflect-cpp")
    set_homepage("https://github.com/getml/reflect-cpp")
    set_description("A C++20 library for fast serialization, deserialization and validation using reflection. Supports JSON, BSON, CBOR, flexbuffers, msgpack, TOML, XML, YAML / msgpack.org[C++20]")
    set_license("MIT")

    add_urls("https://github.com/getml/reflect-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/getml/reflect-cpp.git")

    add_versions("v0.9.0", "a64ad16da970da7d66d71a134312c7d0b7de2f4e1448b83d3ea92130dfe0449c")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <rfl/json.hpp>
            #include <rfl.hpp>

            struct Person {
                std::string first_name;
                std::string last_name;
                int age;
            };

            const auto homer = Person{.first_name = "Homer",
                                      .last_name = "Simpson",
                                      .age = 45};

            void test(int argc, char** argv)
            {
                const std::string json_string = rfl::json::write(homer);
                auto homer2 = rfl::json::read<Person>(json_string).value();
            }   
        ]]}, {includes = {"rfl.hpp", "rfl/json.hpp"}, configs = {languages = "c++20"}}))
    end)
