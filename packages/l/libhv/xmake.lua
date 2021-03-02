package("libhv")

    set_homepage("https://github.com/ithewei/libhv")
    set_description("Like libevent, libev, and libuv, libhv provides event-loop with non-blocking IO and timer, but simpler api and richer protocols.")

    add_urls("https://github.com/ithewei/libhv/archive/v$(version).zip")
    add_versions("1.0.0", "39adb77cc7addaba82b69fa9a433041c8288f3d9c773fa360162e3391dcf6a7b")

    add_configs("protocol",    {description = "compile protocol", default = false, type = "boolean"})
    add_configs("http",        {description = "compile http", default = true, type = "boolean"})
    add_configs("http_server", {description = "compile http/server", default = true, type = "boolean"})
    add_configs("http_client", {description = "compile http/client", default = true, type = "boolean"})
    add_configs("consul",      {description = "compile consul", default = false, type = "boolean"})
    add_configs("ipv6",        {description = "ipv6", default = false, type = "boolean"})
    add_configs("uds",         {description = "Unix Domain Socket", default = false, type = "boolean"})
    add_configs("windump",     {description = "Windows MiniDumpWriteDump", default = false, type = "boolean"})
    add_configs("multimap",    {description = "MultiMap", default = false, type = "boolean"})
    add_configs("curl",        {description = "with curl library", default = false, type = "boolean"})
    add_configs("nghttp2",     {description = "with nghttp2 library", default = false, type = "boolean"})
    add_configs("openssl",     {description = "with openssl library", default = false, type = "boolean"})
    add_configs("mbedtls",     {description = "with mbedtls library", default = false, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_install("windows", "linux", "macosx", "android", "iphoneos", function(package)
        local configs = {"-DBUILD_EXAMPLES=OFF", "-DBUILD_UNITTEST=OFF"}
        table.insert(configs, "-DBUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        for _, name in ipairs({"with_protocol",
                               "with_http",
                               "with_http_server",
                               "with_http_client",
                               "with_consul",
                               "with_curl",
                               "with_nghttp2",
                               "with_openssl",
                               "with_mbedtls",
                               "enable_ipv6",
                               "enable_uds",
                               "enable_windump",
                               "use_multimap"}) do
            local config_name = name:gsub("with_", ""):gsub("use_", ""):gsub("enable_", "")
            table.insert(configs, "-D" .. name:upper() .. "=" .. (package:config(config_name) and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:has_cfuncs("hloop_new", {includes = "hv/hloop.h"}))
    end)
