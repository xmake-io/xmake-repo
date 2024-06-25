package("pahomqttcpp")
    set_homepage("https://github.com/eclipse/paho.mqtt.cpp")
    set_description("Eclipse Paho MQTT C++ Client Library")
    set_license("EPL-2.0")

    add_urls("https://github.com/eclipse/paho.mqtt.cpp/archive/refs/tags/$(version).zip",
             "https://github.com/eclipse/paho.mqtt.cpp.git")

    add_versions("v1.3.2", "e01f43cf0ba35efa666503c7adb2786d4a6f7fe6eb44ce5311ac4785a0ce8a98")
    add_versions("v1.2.0", "90c4d8ae4f56bb706120fddcc5937cd0a0360b6f39d5cd5574a5846c0f923473")
    
    add_configs("openssl", {description = "Flag that defines whether to build ssl-enabled binaries too.", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("pahomqttc", {configs = {asynchronous = true}})

    on_load(function (package)
        if package:config("openssl") then
            package:add("deps", "openssl")
        end

        if package:config("shared") and package:is_plat("windows") then
            package:add("defines", "PAHO_MQTTPP_IMPORTS")
        end
    end)

    on_install("!wasm", function (package)
        local configs = {}
        local shared = package:config("shared")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DPAHO_BUILD_SHARED=" .. (shared and "TRUE" or "FALSE"))
        table.insert(configs, "-DPAHO_BUILD_STATIC=" .. (shared and "FALSE" or "TRUE"))

        table.insert(configs, "-DPAHO_WITH_SSL=" .. (package:config("openssl") and "TRUE" or "FALSE"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <mqtt/client.h>
            void test() {
                mqtt::client cli{"localhost", "some_id"};
                cli.connect();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
