package("pahomqttc")
    set_homepage("https://github.com/eclipse/paho.mqtt.c")
    set_description("Eclipse Paho MQTT C Client Library")
    set_license("MIT")

    add_urls("https://github.com/eclipse/paho.mqtt.c/archive/refs/tags/$(version).zip",
             "https://github.com/eclipse/paho.mqtt.c.git")

    add_versions("v1.3.13", "5ba7c7ab7ebb1499938fa2e358e6c1f9a926b270f2bf082acf89d59b4771a132")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DPAHO_BUILD_SAMPLES=FALSE",
                         "-DPAHO_WITH_SSL=FALSE",
                         "-DPAHO_BUILD_DOCUMENTATION=FALSE"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("MQTTClient_message", {includes = "MQTTClient.h"}))
    end)   
    