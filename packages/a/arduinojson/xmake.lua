package("arduinojson")
    set_kind("library", {headeronly = true})
    set_homepage("https://arduinojson.org")
    set_description("📟 JSON library for Arduino and embedded C++. Simple and efficient.")
    set_license("MIT")

    add_urls("https://github.com/bblanchon/ArduinoJson/archive/refs/tags/$(version).tar.gz",
             "https://github.com/bblanchon/ArduinoJson.git")

    add_versions("v7.3.0", "e2b6739a00c64813169cbcea2d0884cbd63efe2223c0b1307de4e655d87730d8")
    add_versions("v7.2.1", "2780504927533d64cf4256c57de51412b835b327ef4018c38d862b0664d36d4f")
    add_versions("v7.2.0", "d20aefd14f12bd907c6851d1dfad173e4fcd2d993841fa8c91a1d8ab5a71188b")
    add_versions("v7.1.0", "74bc745527a274bcab85c6498de77da749627113c4921ccbcaf83daa7ac35dee")
    add_versions("v7.0.4", "98ca14d98e9f1e8978ce5ad3ca0eeda3d22419d17586c60f299f369078929917")
    add_versions("v7.0.3", "6da2d069e0caa0c829444912ee13e78bdf9cc600be632428a164c92e69528000")
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
