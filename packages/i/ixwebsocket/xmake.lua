package("ixwebsocket")
    set_homepage("https://github.com/machinezone/IXWebSocket")
    set_description("websocket and http client and server library, with TLS support and very few dependencies")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/machinezone/IXWebSocket/archive/refs/tags/$(version).tar.gz",
             "https://github.com/machinezone/IXWebSocket.git")

    add_versions("v11.4.4", "9ef7fba86a91ce18693451466ddc54b1e0c4a7dc4466c3028d888d6d55dde539")

    add_configs("ssl", {description = "Enable SSL", default = nil, type = "string", values = {"openssl", "mbedtls"}})

    add_configs("use_tls", {description = "Use TLS", default = false, type = "boolean"})

    add_deps("zlib")
    if is_plat("windows") then
        add_syslinks("ws2_32")
    elseif is_plat("macosx") then
        add_frameworks("Foundation", "Security")
    end
    add_deps("cmake")

    on_load(function (package)
        if package:config("ssl") == "openssl" then
            package:add("deps", "openssl")
        elseif package:config("ssl") == "mbedtls" then
            package:add("deps", "mbedtls")
        end
    end)

    on_install("windows", "linux", "macosx", "bsd", function (package)
        local configs = {"-DCMAKE_CXX_STANDARD=11"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        table.insert(configs, "-DUSE_TLS=" .. (package:config("use_tls") and "ON" or "OFF"))

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ixwebsocket/IXNetSystem.h>
            #include <ixwebsocket/IXWebSocket.h>
            void test () {
                ix::initNetSystem();
                ix::WebSocket webSocket;
                std::string url("wss://echo.websocket.org");
                webSocket.setUrl(url);
                webSocket.start();
                webSocket.send("Hello world");
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)

