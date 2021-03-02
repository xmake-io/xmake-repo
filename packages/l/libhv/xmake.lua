package("libhv")

    set_homepage("https://github.com/ithewei/libhv")
    set_description("Like libevent, libev, and libuv, libhv provides event-loop with non-blocking IO and timer, but simpler api and richer protocols.")

    add_urls("https://github.com/ithewei/libhv/archive/v$(version).zip")
    add_versions("1.0.0", "39adb77cc7addaba82b69fa9a433041c8288f3d9c773fa360162e3391dcf6a7b")

    add_configs("protocol", {description = "compile protocol", default = false, type = "boolean"})
    add_configs("http", {description = "compile http", default = true, type = "boolean"})
    add_configs("http_server", {description = "compile http/server", default = true, type = "boolean"})
    add_configs("http_client", {description = "compile http/client", default = true, type = "boolean"})
    add_configs("consul", {description = "compile consul", default = false, type = "boolean"})
    add_configs("ipv6", {description = "ipv6", default = false, type = "boolean"})
    add_configs("uds", {description = "Unix Domain Socket", default = false, type = "boolean"})
    add_configs("windump", {description = "Windows MiniDumpWriteDump", default = false, type = "boolean"})
    add_configs("multimap", {description = "MultiMap", default = false, type = "boolean"})
    add_configs("curl", {description = "with curl library", default = false, type = "boolean"})
    add_configs("nghttp2", {description = "with nghttp2 library", default = false, type = "boolean"})
    add_configs("openssl", {description = "with openssl library", default = false, type = "boolean"})
    add_configs("mbedtls", {description = "with mbedtls library", default = false, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load("windows", "linux", "macosx", "android", "iphoneos", function (package)
        if package:config("curl") then
            package:add("deps", "libcurl")
        end
        if package:config("openssl") then
            package:add("deps", "openssl")
        end
        if package:config("mbedtls") then
            package:add("deps", "mbedtls")
        end
    end)

    add_deps("cmake")
    on_install("windows", "linux", "macosx", "android", "iphoneos", function(package)
        local configs = {"-DBUILD_EXAMPLES=OFF", "-DBUILD_UNITTEST=OFF"}
        table.insert(configs, "-DBUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DWITH_PROTOCOL=" .. (package:config("protocol") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_HTTP=" .. (package:config("http") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_HTTP_SERVER=" .. (package:config("http_server") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_HTTP_CLIENT=" .. (package:config("http_client") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_CONSUL=" .. (package:config("consul") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_IPV6=" .. (package:config("ipv6") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_UDS=" .. (package:config("uds") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_WINDUMP=" .. (package:config("windump") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_MULTIMAP=" .. (package:config("multimap") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_CURL=" .. (package:config("curl") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_NGHTTP2=" .. (package:config("nghttp2") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_OPENSSL=" .. (package:config("openssl") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_MBEDTLS=" .. (package:config("mbedtls") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:check_csnippets({test = [[
            #include <hv/hloop.h>
            static void test() {
                hloop_t* loop = hloop_new(0);            
            }
        ]]}, {includes = "hv/hloop.h"}))
    end)
