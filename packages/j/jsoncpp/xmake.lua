package("jsoncpp")

    set_homepage("https://github.com/open-source-parsers/jsoncpp/wiki")
    set_description("A C++ library for interacting with JSON.")

    add_urls("https://github.com/open-source-parsers/jsoncpp/archive/$(version).zip",
             "https://github.com/open-source-parsers/jsoncpp.git")
    add_versions("1.9.4", "6da6cdc026fe042599d9fce7b06ff2c128e8dd6b8b751fca91eb022bce310880")
    add_versions("1.9.5", "a074e1b38083484e8e07789fd683599d19da8bb960959c83751cd0284bdf2043")

    add_deps("cmake")
    on_load(function (package)
        if package:config("shared") then
            package:add("defines", "JSON_DLL")
        end
    end)

    on_install("linux", "macosx", "android", "iphoneos", "windows", "mingw", "cross", function(package)
        local configs = {"-DJSONCPP_WITH_POST_BUILD_UNITTEST=OFF", "-DJSONCPP_WITH_TESTS=OFF", "-DJSONCPP_WITH_EXAMPLE=OFF", "-DBUILD_OBJECT_LIBS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
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
                    JSONCPP_STRING err;
                    Json::Value root;
                    Json::CharReaderBuilder builder;
                    const std::unique_ptr<Json::CharReader> reader(builder.newCharReader());
                    reader->parse(rawJson.c_str(), rawJson.c_str() + rawJsonLength, &root, &err);
                    const std::string name = root["Name"].asString();
                    const int age = root["Age"].asInt();
                    assert(name == "colin");
                    assert(age == 20);
                }
            ]]
        }, {configs = {languages = "c++14"}, includes = "json/json.h"}))
    end)
