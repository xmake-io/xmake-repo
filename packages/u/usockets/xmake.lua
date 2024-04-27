package("usockets")
    set_homepage("https://github.com/uNetworking")
    set_description("µSockets is the non-blocking, thread-per-CPU foundation library used by µWebSockets. It provides optimized networking - using the same opaque API (programming interface) across all supported transports, event-loops and platforms.")
    set_license("Apache-2.0")

    add_urls("https://github.com/uNetworking/uSockets/archive/refs/tags/$(version).tar.gz",
             "https://github.com/uNetworking/uSockets.git")

    add_versions("v0.8.8", "d14d2efe1df767dbebfb8d6f5b52aa952faf66b30c822fbe464debaa0c5c0b17")

    add_configs("ssl", {description = "Select ssl library", default = nil, type = "string", values = {"openssl", "wolfssl", "boringssl"}})

    add_deps("libuv")

    on_load(function (package)
        local ssl = package:config("ssl")
        if ssl then
            package:add("deps", ssl)
        end
    end)

    on_install("windows", "macosx", "linux", "android@linux,macosx", "mingw@linux,macosx", function (package)
        local configs = {}
        configs.ssl = package:config("ssl")

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("us_create_socket_context", {includes = {"libusockets.h"}}))
    end)
