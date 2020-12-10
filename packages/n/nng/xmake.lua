package("nng")

    set_homepage("https://github.com/nanomsg/nng")
    set_description("NNG, like its predecessors nanomsg (and to some extent ZeroMQ), is a lightweight, broker-less library, offering a simple API to solve common recurring messaging problems.")

    add_urls("https://github.com/nanomsg/nng/archive/v$(version).zip")
    add_versions("1.3.2", "2616110016c89ed3cbd458022ba41f4f545ab17f807546d2fdd0789b55d64471")

    -- default is false
    add_configs("NNG_ELIDE_DEPRECATED", {description = "Elide deprecated functionality.", default = false, type = "boolean"})
    add_configs("NNG_TRANSPORT_ZEROTIER", {description = "Enable ZeroTier transport (requires libzerotiercore).", default = false, type = "boolean"})
    add_configs("NNG_ENABLE_TLS", {description = "Enable TLS support.", default = false, type = "boolean"})

    -- default is true
    add_configs("NNG_ENABLE_STATS", {description = "Enable statistics.", default = true, type = "boolean"})
    add_configs("NNG_PROTO_BUS0", {description = "Enable BUSv0 protocol.", default = true, type = "boolean"})
    add_configs("NNG_PROTO_PAIR0", {description = "Enable PAIRv0 protocol.", default = true, type = "boolean"})
    add_configs("NNG_PROTO_PAIR1", {description = "Enable PAIRv1 protocol.", default = true, type = "boolean"})
    add_configs("NNG_PROTO_PUSH0", {description = "Enable PUSHv0 protocol.", default = true, type = "boolean"})
    add_configs("NNG_PROTO_PULL0", {description = "Enable PULLv0 protocol.", default = true, type = "boolean"})
    add_configs("NNG_PROTO_PUB0", {description = "Enable PUBv0 protocol.", default = true, type = "boolean"})
    add_configs("NNG_PROTO_SUB0", {description = "Enable SUBv0 protocol.", default = true, type = "boolean"})
    add_configs("NNG_PROTO_REQ0", {description = "Enable REQv0 protocol.", default = true, type = "boolean"})
    add_configs("NNG_PROTO_REP0", {description = "Enable REPv0 protocol.", default = true, type = "boolean"})
    add_configs("NNG_PROTO_RESPONDENT0", {description = "Enable RESPONDENTv0 protocol.", default = true, type = "boolean"})
    add_configs("NNG_PROTO_SURVEYOR0", {description = "Enable SURVEYORv0 protocol.", default = true, type = "boolean"})
    add_configs("NNG_ENABLE_HTTP", {description = "Enable HTTP API.", default = true, type = "boolean"})
    add_configs("NNG_TRANSPORT_INPROC", {description = "Enable inproc transport.", default = true, type = "boolean"})
    add_configs("NNG_TRANSPORT_IPC", {description = "Enable IPC transport.", default = true, type = "boolean"})
    add_configs("NNG_TRANSPORT_TCP", {description = "Enable TCP transport.", default = true, type = "boolean"})
    add_configs("NNG_TRANSPORT_TLS", {description = "Enable TLS transport.", default = true, type = "boolean"})
    add_configs("NNG_TRANSPORT_WS", {description = "Enable WebSocket transport.", default = true, type = "boolean"})
    add_configs("NNG_TRANSPORT_WSS", {description = "Enable WSS transport.", default = true, type = "boolean"})

    on_load(function (package)
        if package:config("static") then
            package:add("defines", "NNG_STATIC_LIB")
        end
    end)

    add_deps("cmake")
    on_install("windows", "linux", "macosx", "mingw", "android", "iphoneos", function(package)
        local configs = {"-DNNG_TESTS=OFF", "-DNNG_ENABLE_NNGCAT=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_ELIDE_DEPRECATED=" .. (package:config("NNG_ELIDE_DEPRECATED") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_TRANSPORT_ZEROTIER=" .. (package:config("NNG_TRANSPORT_ZEROTIER") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_ENABLE_TLS=" .. (package:config("NNG_ENABLE_TLS") and "ON" or "OFF"))

        table.insert(configs, "-DNNG_ENABLE_STATS=" .. (package:config("NNG_ENABLE_STATS") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_PROTO_BUS0=" .. (package:config("NNG_PROTO_BUS0") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_PROTO_PAIR0=" .. (package:config("NNG_PROTO_PAIR0") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_PROTO_PAIR1=" .. (package:config("NNG_PROTO_PAIR1") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_PROTO_PUSH0=" .. (package:config("NNG_PROTO_PUSH0") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_PROTO_PULL0=" .. (package:config("NNG_PROTO_PULL0") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_PROTO_PUB0=" .. (package:config("NNG_PROTO_PUB0") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_PROTO_SUB0=" .. (package:config("NNG_PROTO_SUB0") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_PROTO_REQ0=" .. (package:config("NNG_PROTO_REQ0") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_PROTO_REP0=" .. (package:config("NNG_PROTO_REP0") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_PROTO_RESPONDENT0=" .. (package:config("NNG_PROTO_RESPONDENT0") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_PROTO_SURVEYOR0=" .. (package:config("NNG_PROTO_SURVEYOR0") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_ENABLE_HTTP=" .. (package:config("NNG_ENABLE_HTTP") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_TRANSPORT_INPROC=" .. (package:config("NNG_TRANSPORT_INPROC") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_TRANSPORT_IPC=" .. (package:config("NNG_TRANSPORT_IPC") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_TRANSPORT_TCP=" .. (package:config("NNG_TRANSPORT_TCP") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_TRANSPORT_TLS=" .. (package:config("NNG_TRANSPORT_TLS") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_TRANSPORT_WS=" .. (package:config("NNG_TRANSPORT_WS") and "ON" or "OFF"))
        table.insert(configs, "-DNNG_TRANSPORT_WSS=" .. (package:config("NNG_TRANSPORT_WSS") and "ON" or "OFF"))

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:check_csnippets({test = [[
            #include <nng/nng.h>
            #include <nng/protocol/reqrep0/req.h>
            #include <nng/supplemental/util/platform.h>
            static void test() {
                nng_socket sock;
                int        rv;
                nng_req0_open(&sock);
                nng_close(sock);
            }
        ]]}, {includes = "nng/nng.h"}))
    end)
