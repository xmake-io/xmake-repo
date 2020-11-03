package("jsoncpp")

set_homepage("https://github.com/open-source-parsers/jsoncpp/wiki")
set_description("A C++ library for interacting with JSON.")

set_urls("https://github.com/open-source-parsers/jsoncpp/archive/$(version).zip")

add_versions("1.9.4", "6da6cdc026fe042599d9fce7b06ff2c128e8dd6b8b751fca91eb022bce310880")

add_includedirs("include")
add_deps("cmake")
on_install("linux", "macosx", function(package)
    local configs = {}
    table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
    table.insert(configs, "-DDBUILD_STATIC_LIBS=" .. (package:config("static") and "ON" or "OFF"))
    table.insert(configs, "-DDCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
    import("package.tools.cmake").install(package, configs)
end)

on_test(function(package)

    assert(package:check_cxxsnippets({
        test = [[
            #include <iostream>
            #include <assert.h>
            static void test() {
                const std::string rawJson = R"({"Age": 20, "Name": "colin"})";
                const auto rawJsonLength = static_cast<int>(rawJson.length());
                constexpr bool shouldUseOldWay = false;
                JSONCPP_STRING err;
                Json::Value root;
                
                if (shouldUseOldWay) {
                  Json::Reader reader;
                  reader.parse(rawJson, root);
                } else {
                  Json::CharReaderBuilder builder;
                  const std::unique_ptr<Json::CharReader> reader(builder.newCharReader());
                  if (!reader->parse(rawJson.c_str(), rawJson.c_str() + rawJsonLength, &root,
                                     &err)) ;
                }
                const std::string name = root["Name"].asString();
                const int age = root["Age"].asInt();
                assert(name == "colin");
                assert(age == 20);
            }
        ]]
    }, {
        configs = {
            languages = "c++11"
        },
        includes = "json/json.h"
    }))
end)
