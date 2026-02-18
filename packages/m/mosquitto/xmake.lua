package("mosquitto")
    set_homepage("https://mosquitto.org")
    set_description("Eclipse Mosquitto - An open source MQTT broker")
    set_license("EPL-2.0")

    add_urls("https://github.com/eclipse/mosquitto/archive/refs/tags/$(version).tar.gz",
             "https://github.com/eclipse/mosquitto.git")

    add_versions("v2.0.15", "547f98acd2e4668c8f3b86ef61e71c755366d180565b6e7537813876467d04d9")
    add_versions("v2.0.18", "25499231664bc5338f9f05eb1815f4d5878f0c6c97e03afb3463a7b139a7e775")
    add_versions("v2.1.2", "20e998aae86d1629e787a924c044bb912d21ac8f5d1c1b707f2af06eb4c6016d")

    if is_plat("windows") then
        add_patches("v2.0.15", path.join(os.scriptdir(), "patches", "2.0.15/cmake.patch"), "b241fb965f3d00bad1fddf060fe9b99cba83df32c373a4eaee2289e05abd26b6")
    end
    add_patches(">=2.1.2", path.join(os.scriptdir(), "patches", "2.1.2/include.patch"), "5fba1ee4d545720d53e358a51fbd8aaf172b1209ad9a8138a9828ec15b17e271")

    add_configs("tls", {description = "Include SSL/TLS support", default = true, type = "boolean"})
    add_configs("cjson", {description = "Build with cJSON support (required for dynamic security plugin and useful for mosquitto_sub)", default = true, type = "boolean"})
    add_configs("bundled_deps", {description = "Build with bundled dependencies", default = true, type = "boolean"})
    add_configs("websockets", {description = "Include websockets support", default = false, type = "boolean"})

    add_configs("tls_psk", {description = "Include TLS-PSK support (requires WITH_TLS)", default = true, type = "boolean"})
    add_configs("ec", {description = "Include Elliptic Curve support (requires WITH_TLS)", default = true, type = "boolean"})
    add_configs("unix_sockets", {description = "Include Unix Domain Socket support", default = true, type = "boolean"})
    add_configs("socks", {description = "Include SOCKS5 support", default = true, type = "boolean"})
    -- disabled because pthreads4w has poor support
    add_configs("threading", {description = "Include client library threading support", default = false, type = "boolean"})
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
        tls             = "openssl3",
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
        if package:version():eq("2.0.18") and package:is_plat("windows") and package:is_arch("arm.*") then
            raise("mosquitto 2.0.18 not support windows arm")
        end
    end)

    on_install("windows|!arm*", "linux", "macosx", function (package)
        if package:version():ge("2.0.18") and package:is_plat("windows") then
            io.replace("CMakeLists.txt", 'add_definitions("-D_CRT_SECURE_NO_WARNINGS")', 'add_definitions("-D_CRT_SECURE_NO_WARNINGS")\nadd_definitions("-DWIN32")\nadd_definitions("-D_WIN32")', {plain = true})
        end
        local configs ={"-DDOCUMENTATION=OFF", "-DWITH_CLIENTS=OFF", "-DWITH_APPS=OFF", "-DWITH_PLUGINS=OFF", "-DWITH_DOCS=OFF", "-DWITH_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DWITH_STATIC_LIBRARIES=" .. (package:config("shared") and "OFF" or "ON"))

        for name, value in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-DWITH_" .. name:upper() .. "=" .. (value and "ON" or "OFF"))
            end
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
