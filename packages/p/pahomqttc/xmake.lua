package("pahomqttc")
    set_homepage("https://github.com/eclipse/paho.mqtt.c")
    set_description("Eclipse Paho MQTT C Client Library")
    set_license("EPL v2.0")

    add_urls("https://github.com/eclipse/paho.mqtt.c/archive/refs/tags/$(version).zip",
             "https://github.com/eclipse/paho.mqtt.c.git")

    add_versions("v1.3.13", "5ba7c7ab7ebb1499938fa2e358e6c1f9a926b270f2bf082acf89d59b4771a132")

    add_configs("uuid", {description = "Flag that defines whether libuuid or a custom uuid implementation should be used", default = false, type = "boolean"})
    add_configs("openssl", {description = "Flag that defines whether to build ssl-enabled binaries too.", default = false, type = "boolean"})

    if is_plat("windows") then
        add_syslinks("ws2_32", "advapi32", "rpcrt4")
    elseif is_plat("linux") then
        add_syslinks("dl", "pthread", "rt")
    elseif is_plat("android") then
        add_syslinks("dl")
    elseif is_plat("bsd") then
        add_syslinks("compat", "pthread")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("uuid") then
            package:add("deps", "uuid")
        end
        if package:config("openssl") then
            package:add("deps", "openssl")
        end

        if package:config("shared") and package:is_plat("windows") then
            package:add("defines", "PAHO_MQTT_IMPORTS")
        end
    end)

    on_install(function (package)
        local configs = {
            "-DPAHO_BUILD_SAMPLES=FALSE",
            "-DPAHO_ENABLE_TESTING=OFF",
            "-DPAHO_ENABLE_CPACK=OFF",
            "-DPAHO_BUILD_DOCUMENTATION=FALSE",
        }
        local shared = package:config("shared")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DPAHO_BUILD_SHARED=" .. (shared and "TRUE" or "FALSE"))
        table.insert(configs, "-DPAHO_BUILD_STATIC=" .. (shared and "FALSE" or "TRUE"))

        table.insert(configs, "-DPAHO_WITH_SSL=" .. (package:config("openssl") and "TRUE" or "FALSE"))
        table.insert(configs, "-DPAHO_WITH_LIBUUID=" .. (package:config("uuid") and "TRUE" or "FALSE"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("MQTTClient_connect", {includes = "MQTTClient.h"}))
    end)
