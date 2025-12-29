package("json-schema-validator")
    set_homepage("https://github.com/pboettch/json-schema-validator")
    set_description("JSON schema validator for JSON for Modern C++")
    set_license("MIT")

    add_urls("https://github.com/pboettch/json-schema-validator/archive/refs/tags/$(version).tar.gz",
             "https://github.com/pboettch/json-schema-validator.git")

    add_versions("2.4.0", "24cbb114609cc9b43d4018b8d03e082ff5d2f26f5dce8bd36538097267b63af9")
    add_versions("2.3.0", "2c00b50023c7d557cdaa71c0777f5bcff996c4efd7a539e58beaa4219fa2a5e1")
    add_versions("2.1.0", "83f61d8112f485e0d3f1e72d51610ba3924b179926a8376aef3c038770faf202")

    if is_host("windows") then
        set_policy("platform.longpaths", true)
    end

    add_deps("cmake")
    add_deps("nlohmann_json", {configs = {cmake = true}})

    on_install(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "JSON_SCHEMA_VALIDATOR_IMPORTS")
        end

        local configs = {
            "-DJSON_VALIDATOR_BUILD_EXAMPLES=OFF",
            "-DJSON_VALIDATOR_BUILD_TESTS=OFF",
            "-DBUILD_TESTS=OFF", -- 2.1.0 option
            "-DBUILD_EXAMPLES=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DJSON_VALIDATOR_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
        #include <nlohmann/json-schema.hpp>

        using nlohmann::json;
        using nlohmann::json_schema::json_validator;

        static json person_schema = R"({})"_json;
        static void test() {
            json_validator validator;
            validator.set_root_schema(person_schema);
        }
        ]]}, {configs = {languages = "c++17"}}))
    end)
