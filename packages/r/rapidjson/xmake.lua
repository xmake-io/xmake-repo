package("rapidjson")

    set_homepage("https://github.com/Tencent/rapidjson")
    set_description("RapidJSON is a JSON parser and generator for C++.")

    set_urls("https://github.com/Tencent/rapidjson.git")

    on_install(function (package)
        os.cp(path.join("include", "*"), package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test()
            {
                const char* json = "{\"project\":\"rapidjson\",\"stars\":10}";
                rapidjson::Document d;
                d.Parse(json);

                rapidjson::StringBuffer buffer;
                rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
                d.Accept(writer);
            }
        ]]}, {configs = {languages = "c++11"}, includes = { "rapidjson/document.h", "rapidjson/stringbuffer.h", "rapidjson/writer.h"} }))
    end)
