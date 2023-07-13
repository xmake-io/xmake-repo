package("mosquitto")
    set_homepage("https://mosquitto.org")
    set_description("Eclipse Mosquitto - An open source MQTT broker")
    set_license("EPL-2.0")
 
    add_urls("https://github.com/eclipse/mosquitto/archive/refs/tags/$(version).tar.gz",
             "https://github.com/eclipse/mosquitto.git")
 
    add_versions("v2.0.15", "26dc3f1758b00c1725a0e4dd32f40c61f374375717f09b6af2bac62c5b44f1eb")

    add_patches("v2.0.15", path.join(os.scriptdir(), "patches", "cmake.patch"),"d81634251dec42facea2bd5c50b3d1988426003a1a4b7e57543e65a92eb051f1")
 
    add_configs("ssl", {description = "Include SSL/TLS support", default = true, type = "boolean"})
    add_configs("cjson", {description = "Build with cJSON support (required for dynamic security plugin and useful for mosquitto_sub)", default = true, type = "boolean"})
    add_configs("bundled", {description = "Build with bundled dependencies", default = true, type = "boolean"})
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
 
    add_configs("cpp", {description = "Build C++ library", default = true, type = "boolean"})
    add_configs("client", {description = "Build clients", default = false, type = "boolean"})
    add_configs("broker", {description = "Build broker", default = true, type = "boolean"})
    add_configs("apps", {description = "Build apps", default = true, type = "boolean"})
    add_configs("plugins", {description = "Build plugins", default = false , type = "boolean"})
 
    add_deps("cmake")
 
    if is_plat("macosx") then
        add_extsources("brew::mosquitto")
    end
 
    local deps_map =
    {
        ssl        = "openssl",
        cjson      = "cjson",
        bundled    = "uthash",
        srv        = "c-ares",
        websockets = "libwebsockets",
    }

    if is_plat("linux") then
        add_syslinks("pthread", "m")
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
        if is_plat("linux") then
            table.insert(configs, "-DWITH_THREADING=" .. (package:config("threading") and "ON" or "OFF"))
            table.insert(configs, "-DWITH_SRV=" .. (package:config("srv") and "ON" or "OFF"))
        else
            table.insert(configs, "-DWITH_THREADING=OFF")
            table.insert(configs, "-DWITH_SRV=OFF")
        end
 
        local configs_map =
        {
            ssl     = "WITH_TLS",
            cjson   = "WITH_CJSON",
            bundled = "WITH_BUNDLED_DEPS",
            websockets = "WITH_WEBSOCKETS",
 
            tls_psk      = "WITH_TLS_PSK",
            ec           = "WITH_EC",
            unix_sockets = "WITH_UNIX_SOCKETS",
            socks        = "WITH_SOCKS",
            srv          = "WITH_SRV",
            threading    = "WITH_THREADING",
            dlt          = "WITH_DLT",
 
            cpp     = "WITH_LIB_CPP",
            client  = "WITH_CLIENTS",
            broker  = "WITH_BROKER",
            apps    = "WITH_APPS",
            plugins = "WITH_PLUGINS",
        }
 
        for key, value in pairs(configs_map) do
            table.insert(configs, "-D" .. value .. "=" .. (package:config(key) and "ON" or "OFF"))
        end
 
        local packagedeps = {}
        for key, value in pairs(deps_map) do
            if package:config(key) then
                table.insert(packagedeps, value)
            end
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
    end)
    
    add_links("mosquittopp", "mosquitto")
 
    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <mosquitto.h>
            void test() {
                mosquitto_lib_init();
            }
        ]]}))
    end)
 