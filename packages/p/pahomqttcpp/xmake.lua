package("pahomqttcpp")
    set_homepage("https://github.com/eclipse/paho.mqtt.cpp")
    set_description("Eclipse Paho MQTT C++ Client Library")
    set_license("EPL-2.0")

    add_urls("https://github.com/eclipse/paho.mqtt.cpp/archive/refs/tags/$(version).zip",
             "https://github.com/eclipse/paho.mqtt.cpp.git", {submodules = false})

    add_versions("v1.5.3", "16b3786d265aa03693f472d72e74bac749204a97310108f8e162bff26123ba51")
    add_versions("v1.5.2", "121ddfc8f35080f01ddf5c0e6557593cc34380623566d78639335d050ce20fb2")
    add_versions("v1.5.1", "ad80c9cdf4c2e557fe0afb95e3170c818bd8f072c7efe6f19e174814d482c131")
    add_versions("v1.5.0", "0805f9d8003b80d3d389930bfb8d369c56cdea402effa76b6c1c61ba5aa0d804")
    add_versions("v1.4.1", "a3b2782ef6d19ff2ac4c6cfe29de79d8888f75122deb361ae91ca3d3a14456ee")
    add_versions("v1.4.0", "c165960f64322de21697eb06efdca3d74cce90f45ff5ff0efdd968708e13ba0c")
    add_versions("v1.3.2", "e01f43cf0ba35efa666503c7adb2786d4a6f7fe6eb44ce5311ac4785a0ce8a98")
    add_versions("v1.2.0", "90c4d8ae4f56bb706120fddcc5937cd0a0360b6f39d5cd5574a5846c0f923473")
    
    add_configs("openssl", {description = "Flag that defines whether to build ssl-enabled binaries too.", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("openssl") then
            package:add("deps", "openssl")
        end

        local opt = {configs = {asynchronous = true}}
        if package:config("shared") then
            opt.configs.shared = true
            if package:is_plat("windows") then
                package:add("defines", "PAHO_MQTTPP_IMPORTS")
            end
        end

        package:add("deps", "pahomqttc", opt)
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
        local languages
        if package:version() and package:version():ge("1.5.0") then
            languages = "c++17"
        else
            languages = "c++11"
        end
        assert(package:check_cxxsnippets({test = [[
            #include <mqtt/client.h>
            void test() {
                mqtt::client cli{"localhost", "some_id"};
                cli.connect();
            }
        ]]}, {configs = {languages = languages}}))
    end)
