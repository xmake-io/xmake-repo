package("json-schema-validator")
    set_homepage("https://github.com/pboettch/json-schema-validator")
    set_description("JSON schema validator for JSON for Modern C++")

    add_urls("https://github.com/pboettch/json-schema-validator/archive/refs/tags/$(version).tar.gz",
             "https://github.com/pboettch/json-schema-validator.git")
    add_versions("2.1.0", "83f61d8112f485e0d3f1e72d51610ba3924b179926a8376aef3c038770faf202")
    add_versions("2.3.0", "2c00b50023c7d557cdaa71c0777f5bcff996c4efd7a539e58beaa4219fa2a5e1")

    add_deps("cmake", "nlohmann_json")

    if is_plat("mingw", "windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_host("windows") then
        set_policy("platform.longpaths", true)
    end

    on_install("linux", "bsd", "windows", "macosx", "iphoneos", "mingw", "cross", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DJSON_VALIDATOR_BUILD_EXAMPLES=OFF")
        table.insert(configs, "-DJSON_VALIDATOR_BUILD_TESTS=OFF")
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
