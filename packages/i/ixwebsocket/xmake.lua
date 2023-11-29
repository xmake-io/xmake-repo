package("ixwebsocket")
    set_homepage("https://github.com/machinezone/IXWebSocket")
    set_description("websocket and http client and server library, with TLS support and very few dependencies")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/machinezone/IXWebSocket/archive/refs/tags/$(version).tar.gz",
             "https://github.com/machinezone/IXWebSocket.git")

    add_versions("v11.4.4", "9ef7fba86a91ce18693451466ddc54b1e0c4a7dc4466c3028d888d6d55dde539")

    local default_ssl = nil
    if not is_plat("windows") then
        if is_plat("iphoneos") or is_plat("wasm") then
            default_ssl = "mbedtls"
        else
            default_ssl = "openssl"
        end
    end
    add_configs("ssl", {description = "Enable SSL", default = default_ssl, type = "string", values = {"openssl", "mbedtls"}})
    add_configs("use_tls", {description = "Use TLS", default = false, type = "boolean"})

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("zlib")
    if is_plat("windows") then
        add_syslinks("ws2_32", "crypt32")
    elseif is_plat("macosx") then
        add_frameworks("Foundation", "Security")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end
    add_deps("cmake")

    on_load(function (package)
        if package:config("ssl") == "openssl" then
            package:add("deps", "openssl")
        elseif package:config("ssl") == "mbedtls" then
            package:add("deps", "mbedtls")
        end
        if package:config("use_tls") then
            if is_plat("windows") then
                if not package:dep("openssl") then
                    package:add("deps", "mbedtls")
                end
            elseif not package:dep("mbedtls") then
                package:add("deps", "openssl")
            end
        end
    end)

    on_install(function (package)
        local configs = {"-DCMAKE_CXX_STANDARD=11"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_TLS=" .. (package:config("use_tls") and "ON" or "OFF"))
        if package:dep("openssl") then
            table.insert(configs, "-DUSE_OPEN_SSL=1")
        elseif package:dep("mbedtls") then
            table.insert(configs, "-DUSE_MBED_TLS=1")
        end 

        local zlib = package:dep("zlib")
        if zlib and not zlib:is_system() then
            local fetchinfo = zlib:fetch({external = false})
            if fetchinfo then
                local includedirs = fetchinfo.includedirs or fetchinfo.sysincludedirs
                if includedirs and #includedirs > 0 then
                    table.insert(configs, "-DZLIB_INCLUDE_DIR=" .. table.concat(includedirs, " "))
                end
                local libfiles = fetchinfo.libfiles
                if libfiles then
                    table.insert(configs, "-DZLIB_LIBRARY=" .. table.concat(libfiles, " "))
                end
            end
        end

        if is_plat("wasm") then
            io.replace("ixwebsocket/IXUserAgent.cpp", [[ss << " " << PLATFORM_NAME]], [[ss << " " << "unknown platform"]], {plain = true})
        end

        io.replace("ixwebsocket/IXSocketMbedTLS.cpp", [[/* errorMsg */]], [[errorMsg]], {plain = true})
        
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ixwebsocket/IXNetSystem.h>
            #include <ixwebsocket/IXWebSocket.h>
            void test() {
                ix::initNetSystem();
                ix::WebSocket webSocket;
                std::string url("wss://echo.websocket.org");
                webSocket.setUrl(url);
                webSocket.start();
                webSocket.send("Hello world");
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)

