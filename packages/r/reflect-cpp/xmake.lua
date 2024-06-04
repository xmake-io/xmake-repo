package("reflect-cpp")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/getml/reflect-cpp")
    set_description("A C++20 library for fast serialization, deserialization and validation using reflection. Supports JSON, BSON, CBOR, flexbuffers, msgpack, TOML, XML, YAML / msgpack.org[C++20]")
    set_license("MIT")

    add_urls("https://github.com/getml/reflect-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/getml/reflect-cpp.git")

    add_versions("v0.9.0", "a64ad16da970da7d66d71a134312c7d0b7de2f4e1448b83d3ea92130dfe0449c")

    add_configs("json", { description = "OnEnable Json Support.", default = true, type = "boolean"})
    --add_configs("with_bson", { description = "OnEnable Bson Support.", default = false, type = "boolean"})
    add_configs("cbor", { description = "OnEnable Cbor Support.", default = false, type = "boolean"})
    add_configs("flatbuffers", { description = "OnEnable Flexbuffers Support.", default = false, type = "boolean"})
    add_configs("msgpack", { description = "OnEnable Msgpack Support.", default = false, type = "boolean"})
    add_configs("xml", { description = "OnEnable Xml Support.", default = false, type = "boolean"})
    add_configs("toml", { description = "OnEnable Toml Support.", default = false, type = "boolean"})
    add_configs("yaml", { description = "OnEnable Yaml Support.", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("json") then
            package:add("deps", "yyjson")
        end

        if package:config("cbor") then
            package:add("deps", "tinycbor")
        end

        if package:config("flatbuffers") then
            package:add("deps", "flatbuffers")
        end

        if package:config("msgpack") then
            package:add("deps", "msgpack-c")
        end
        
        if package:config("xml") then
            package:add("deps", "pugixml")
        end

        if package:config("toml") then
            package:add("deps", "tomlcpp")
        end

        if package:config("yaml") then
            package:add("deps", "yaml-cpp")
        end          
    end)


    on_install(function (package)
         os.cp("include", package:installdir())
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
