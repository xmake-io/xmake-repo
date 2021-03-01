package("libhv")

    set_homepage("https://github.com/ithewei/libhv")
    set_description("Like libevent, libev, and libuv, libhv provides event-loop with non-blocking IO and timer, but simpler api and richer protocols.")

    add_urls("https://github.com/ithewei/libhv/archive/v$(version).zip")
    add_versions("1.0.0", "39adb77cc7addaba82b69fa9a433041c8288f3d9c773fa360162e3391dcf6a7b")

    add_configs("BUILD_SHARED", {description = "build shared library", default = false, type = "boolean"})
    add_configs("BUILD_STATIC", {description = "build static library", default = true, type = "boolean"})
    add_configs("WITH_PROTOCOL", {description = "compile protocol", default = false, type = "boolean"})
    add_configs("WITH_HTTP", {description = "compile http", default = true, type = "boolean"})
    add_configs("WITH_HTTP_SERVER", {description = "compile http/server", default = true, type = "boolean"})
    add_configs("WITH_HTTP_CLIENT", {description = "compile http/client", default = true, type = "boolean"})
    add_configs("WITH_CONSUL", {description = "compile consul", default = false, type = "boolean"})
    add_configs("ENABLE_IPV6", {description = "ipv6", default = false, type = "boolean"})
    add_configs("ENABLE_UDS", {description = "Unix Domain Socket", default = false, type = "boolean"})
    add_configs("ENABLE_WINDUMP", {description = "Windows MiniDumpWriteDump", default = false, type = "boolean"})
    add_configs("USE_MULTIMAP", {description = "MultiMap", default = false, type = "boolean"})
    add_configs("WITH_CURL", {description = "with curl library", default = false, type = "boolean"})
    add_configs("WITH_NGHTTP2", {description = "with nghttp2 library", default = false, type = "boolean"})
    add_configs("WITH_OPENSSL", {description = "with openssl library", default = false, type = "boolean"})
    add_configs("WITH_MBEDTLS", {description = "with mbedtls library", default = false, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    on_install("windows", "linux", "macosx", "android", "iphoneos", function(package)
        local configs = {"-DBUILD_EXAMPLES=OFF", "-DBUILD_UNITTEST=OFF"}
        table.insert(configs, "-DBUILD_SHARED=" .. ((package:config("shared") or package:config("BUILD_SHARED")) and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC=" .. ((package:config("static") or package:config("BUILD_STATIC")) and "ON" or "OFF"))
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-D" .. name .. "=" .. (enabled and "ON" or "OFF"))
            end
        end
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
