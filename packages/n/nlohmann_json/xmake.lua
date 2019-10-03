package("nlohmann_json")

    set_homepage("https://nlohmann.github.io/json/")
    set_description("JSON for Modern C++")

    add_urls("https://github.com/nlohmann/json/releases/download/$(version)/include.zip",
             "https://github.com/nlohmann/json.git")
    add_versions("v3.4.0", "bfec46fc0cee01c509cf064d2254517e7fa80d1e7647fea37cf81d97c5682bdc")
    add_versions("v3.7.0", "541c34438fd54182e9cdc68dd20c898d766713ad6d901fb2c6e28ff1f1e7c10d")

    on_install(function (package)
        if os.isdir("include") then
            os.cp("include", package:installdir())
        else
            os.cp("*", package:installdir("include"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using json = nlohmann::json;
            void test() {
                json data;
                data["name"] = "world";
            }
        ]]}, {configs = {languages = "c++14"}, includes = {"nlohmann/json.hpp"}}))
    end)
