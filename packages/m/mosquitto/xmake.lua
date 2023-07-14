package("mosquitto")
    set_homepage("https://mosquitto.org")
    set_description("Eclipse Mosquitto - An open source MQTT broker")
    set_license("EPL-2.0")
 
    add_urls("https://github.com/eclipse/mosquitto/archive/refs/tags/$(version).tar.gz",
             "https://github.com/eclipse/mosquitto.git")
 
    add_versions("v2.0.15", "547f98acd2e4668c8f3b86ef61e71c755366d180565b6e7537813876467d04d9")

    if is_plat("windows") then
        add_patches("v2.0.15", path.join(os.scriptdir(), "patches", "cmake.patch"),"b241fb965f3d00bad1fddf060fe9b99cba83df32c373a4eaee2289e05abd26b6")
    end 

    add_configs("tls", {description = "Include SSL/TLS support", default = true, type = "boolean"})
    add_configs("cjson", {description = "Build with cJSON support (required for dynamic security plugin and useful for mosquitto_sub)", default = true, type = "boolean"})
    add_configs("bundled_deps", {description = "Build with bundled dependencies", default = true, type = "boolean"})
    add_configs("websockets", {description = "Include websockets support", default = false, type = "boolean"})
 
    add_configs("tls_psk", {description = "Include TLS-PSK support (requires WITH_TLS)", default = true, type = "boolean"})
    add_configs("ec", {description = "Include Elliptic Curve support (requires WITH_TLS)", default = true, type = "boolean"})
    add_configs("unix_sockets", {description = "Include Unix Domain Socket support", default = true, type = "boolean"})
    add_configs("socks", {description = "Include SOCKS5 support", default = true, type = "boolean"})
    add_configs("threading", {description = "Include client library threading support", default = true, type = "boolean"})
    if is_plat("linux") then
        add_configs("srv", {description = "Include SRV lookup support", default = true, type = "boolean"})
    end
    add_configs("dlt", {description = "Include DLT support", default = false, type = "boolean"})
 
    add_configs("lib_cpp", {description = "Build C++ library", default = true, type = "boolean"})
    add_configs("broker", {description = "Build broker", default = false, type = "boolean"})
 
    add_deps("cmake")
 
    if is_plat("macosx") then
        add_extsources("brew::mosquitto")
    end
 
    local deps_map =
    {
        tls             = "openssl",
        cjson           = "cjson",
        bundled_deps    = "uthash",
        srv             = "c-ares",
        websockets      = "libwebsockets",
    }

    if is_plat("linux") then
        add_syslinks("pthread", "m")
        add_links("mosquittopp", "mosquitto")
    elseif is_plat("windows") then
        add_syslinks("ws2_32")
        deps_map["threading"] = "pthreads4w"
    end
 
    on_load("windows", "linux", "macosx", function (package)
        for key, value in pairs(deps_map) do
            if package:config(key) then
                package:add("deps", value)
            end
        end
    end)
 
    on_install("windows", "linux", "macosx", function (package)
        local configs ={"-DDOCUMENTATION=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DWITH_STATIC_LIBRARIES=" .. (package:config("shared") and "OFF" or "ON"))
 
        local configs_list =
        {
            "tls",
            "cjson",
            "bundled_deps",
            "websockets",
 
            "tls_psk",
            "ec",
            "unix_sockets",
            "socks",
            "srv",
            "threading",
            "dlt",
 
            "lib_cpp",
            "clients",
            "broker", 
            "apps",  
            "plugins", 
        }

        for _, value in ipairs(configs_list) do
            table.insert(configs, "-DWITH_" .. value:upper() .. "=" .. (package:config(value) and "ON" or "OFF"))
        end
 
        local packagedeps = {}
        for key, value in pairs(deps_map) do
            if package:config(key) then
                table.insert(packagedeps, value)
            end
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
    end)
    
    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <mosquitto.h>
            void test() {
                mosquitto_lib_init();
            }
        ]]}))
    end)