package("pahomqttc")
    set_homepage("https://github.com/eclipse/paho.mqtt.c")
    set_description("Eclipse Paho MQTT C Client Library")
    set_license("EPL-2.0")

    add_urls("https://github.com/eclipse/paho.mqtt.c/archive/refs/tags/$(version).zip",
             "https://github.com/eclipse/paho.mqtt.c.git")

    add_versions("v1.3.15", "d64ea8d1c4ea10c76a7553fedb7de60c60c05a655c4dae1580bb1ff902bd85b9")
    add_versions("v1.3.14", "ad67f3920b4dc618867c573626f6dbddc213d3f759abbdb9d785f7f85d086e41")
    add_versions("v1.3.13", "5ba7c7ab7ebb1499938fa2e358e6c1f9a926b270f2bf082acf89d59b4771a132")

    add_configs("uuid", {description = "Flag that defines whether libuuid or a custom uuid implementation should be used", default = false, type = "boolean"})
    add_configs("openssl", {description = "Flag that defines whether to build ssl-enabled binaries too.", default = false, type = "boolean"})
    add_configs("high_performance", {description = "Enable tracing and heap tracking", default = false, type = "boolean"})
    add_configs("asynchronous", {description = "Use asynchronous", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "advapi32", "rpcrt4", "crypt32")
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

        if package:config("shared") and package:is_plat("windows") then
            package:add("defines", "PAHO_MQTT_IMPORTS")
        end
        -- paho-mqtt3[a|c][s][-static]
        local links = "paho-mqtt3" .. (package:config("asynchronous") and "a" or "c")
        if package:config("openssl") then
            links = links .. "s"
            package:add("deps", "openssl")
        end
        if package:is_plat("windows", "mingw") and (not package:config("shared")) then
            links = links .. "-static"
        end
        package:add("links", links)
    end)

    on_install("!wasm", function (package)
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
        table.insert(configs, "-DPAHO_HIGH_PERFORMANCE=" .. (package:config("high_performance") and "TRUE" or "FALSE"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        if package:config("asynchronous") then
            assert(package:has_cfuncs("MQTTAsync_connect", {includes = "MQTTAsync.h"}))
        else
            assert(package:has_cfuncs("MQTTClient_connect", {includes = "MQTTClient.h"}))
        end
    end)
