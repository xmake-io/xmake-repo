package("pahomqttcpp")
    set_homepage("https://github.com/eclipse/paho.mqtt.cpp")
    set_description("Eclipse Paho MQTT C++ Client Library")
    set_license("EPL v1.0")

    add_urls("https://github.com/eclipse/paho.mqtt.cpp/archive/refs/tags/$(version).zip",
             "https://github.com/eclipse/paho.mqtt.cpp.git")

    add_versions("v1.3.2", "e01f43cf0ba35efa666503c7adb2786d4a6f7fe6eb44ce5311ac4785a0ce8a98")
    add_versions("v1.2.0", "90c4d8ae4f56bb706120fddcc5937cd0a0360b6f39d5cd5574a5846c0f923473")
    
    add_deps("cmake")
    add_deps("pahomqttc")

    on_install("windows", "linux", "macosx", function (package)
        
        local configs = {"-DPAHO_WITH_SSL=FALSE"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        if package:is_plat("windows") then
            local pahomqttc = package:dep("pahomqttc"):fetch()

            local includedirs = pahomqttc.includedirs or pahomqttc.sysincludedirs
            if includedirs and #includedirs > 0 then
                table.insert(configs, "-DPAHO_MQTT_C_INCLUDE_DIRS=" .. table.concat(includedirs, " "))
            end

            local libfiles = pahomqttc.libfiles
            if libfiles then
                table.insert(configs, "-DPAHO_MQTT_C_LIBRARIES=" .. table.concat(libfiles, " "))
            end
        end
        
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
