package("pahomqttcpp")
    set_homepage("https://github.com/eclipse/paho.mqtt.cpp")
    set_description("Eclipse Paho MQTT C++ Client Library")
    set_license("EPL v1.0")

    add_urls("https://github.com/eclipse/paho.mqtt.cpp/archive/refs/tags/$(version).zip",
             "https://github.com/eclipse/paho.mqtt.cpp.git")

    add_versions("v1.2.0", "90c4d8ae4f56bb706120fddcc5937cd0a0360b6f39d5cd5574a5846c0f923473")
    
    add_deps("cmake")
    add_deps("pahomqttc")

    on_install("windows", "linux", "macos", function (package)
        local pahomqttc = package:dep("pahomqttc")
        
        local configs = {"-DPAHO_BUILD_SAMPLES=FALSE",
                         "-DPAHO_WITH_SSL=FALSE",
                         "-DPAHO_BUILD_DOCUMENTATION=FALSE"}
        table.insert(configs, "-DCMAKE_PREFIX_PATH=" .. pahomqttc:installdir())
        if is_plat("windows") then
            table.insert(configs, "-DPAHO_MQTT_C_LIBRARIES=" .. pahomqttc:installdir("lib"))
            table.insert(configs, "-DPAHO_MQTT_C_INCLUDE_DIRS=" .. pahomqttc:installdir("include"))
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
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
