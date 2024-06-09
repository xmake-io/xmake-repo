package("usockets")
    set_homepage("https://github.com/uNetworking")
    set_description("µSockets is the non-blocking, thread-per-CPU foundation library used by µWebSockets. It provides optimized networking - using the same opaque API (programming interface) across all supported transports, event-loops and platforms.")
    set_license("Apache-2.0")

    add_urls("https://github.com/uNetworking/uSockets/archive/refs/tags/$(version).tar.gz",
             "https://github.com/uNetworking/uSockets.git")

    add_versions("v0.8.8", "d14d2efe1df767dbebfb8d6f5b52aa952faf66b30c822fbe464debaa0c5c0b17")

    add_configs("ssl", {description = "Select ssl library", default = nil, type = "string", values = {"openssl", "wolfssl", "boringssl"}})
    add_configs("uv", {description = "Enable libuv", default = false, type = "boolean"})
    add_configs("uring", {description = "Enable liburing", default = false, type = "boolean"})
    add_configs("quic", {description = "Enable lsquic", default = false, type = "boolean"})

    on_load(function (package)
        local ssl = package:config("ssl")
        if ssl then
            package:add("deps", ssl)
            if ssl == "openssl" or ssl == "boringssl" then
                package:add("defines", "LIBUS_USE_OPENSSL")
            elseif ssl == "wolfssl" then
                package:add("defines", "LIBUS_USE_WOLFSSL")
            end
        else
            package:add("defines", "LIBUS_NO_SSL")
        end

        if package:is_plat("windows") then
            package:add("deps", "libuv")
            package:config_set("uv", true)
        else
            if package:config("libuv") then
                package:add("deps", "libuv")
                package:add("defines", "LIBUS_USE_LIBUV")
            end
        end

        if package:is_plat("linux") and package:config("uring") then
            package:add("deps", "liburing")
            package:add("defines", "LIBUS_USE_IO_URING")
        end

        if package:config("quic") then
            package:add("deps", "lsquic")
            package:add("defines", "LIBUS_USE_QUIC")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {}
        configs.ssl = package:config("ssl")
        configs.uv = package:config("uv")
        configs.uring = package:config("uring")
        configs.quic = package:config("quic")

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("us_create_socket_context", {includes = {"libusockets.h"}}))
    end)
