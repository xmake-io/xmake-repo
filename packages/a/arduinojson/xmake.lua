package("arduinojson")
    set_kind("library", {headeronly = true})
    set_homepage("https://arduinojson.org")
    set_description("📟 JSON library for Arduino and embedded C++. Simple and efficient.")
    set_license("MIT")

    add_urls("https://github.com/bblanchon/ArduinoJson/archive/refs/tags/$(version).tar.gz",
             "https://github.com/bblanchon/ArduinoJson.git")

    add_versions("v6.21.4", "9551af9282372f6e64cf4009fc43be7f2df6eb96fe9c0aab44d4eed217d09747")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package, {"-DBUILD_TESTING=OFF"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ArduinoJson.h>
            void test() {
                char json[] = "{\"sensor\":\"gps\",\"time\":1351824120,\"data\":[48.756080,2.302038]}";
                DynamicJsonDocument doc(1024);
                deserializeJson(doc, json);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
