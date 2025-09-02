package("libdatachannel")
    set_homepage("https://libdatachannel.org/")
    set_description("C/C++ WebRTC network library featuring Data Channels, Media Transport, and WebSockets")
    set_license("MPL-2.0")

    add_urls("https://github.com/paullouisageneau/libdatachannel/archive/refs/tags/$(version).tar.gz",
             "https://github.com/paullouisageneau/libdatachannel.git", {submodules = false})

    add_versions("v0.23.1", "63e14d619ac4d9cc310a0c7620b80e6da88abf878f27ccc78cd099f95d47b121")

    add_configs("gnutls", {description = "Use GnuTLS instead of OpenSSL", default = false, type = "boolean"})
    add_configs("mbedtls", {description = "Use Mbed TLS instead of OpenSSL", default = false, type = "boolean"})
    add_configs("nice", {description = "Use libnice instead of libjuice", default = false, type = "boolean", readonly = true})
    add_configs("websocket", {description = "Enable WebSocket support", default = false, type = "boolean"})
    add_configs("media", {description = "Enable media transport support", default = false, type = "boolean"})
    add_configs("capi_stdcall", {description = "Set calling convention of C API callbacks stdcall", default = false, type = "boolean"})
    add_configs("sctp_debug", {description = "Enable SCTP debugging output to verbose log", default = false, type = "boolean"})
    add_configs("rtc_update_version_header", {description = "Enable updating the version header", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    add_deps("plog", "usrsctp", "libjuice")
    add_deps("nlohmann_json", {configs = {cmake = true}})

    on_check("wasm", function (target)
        raise("package(libdatachannel) dep(usrsctp) unsupported wasm platform")
    end)

    on_load(function (package)
        if package:config("mbedtls") then
            package:add("deps", "mbedtls")
        else
            package:add("deps", "openssl3")
        end
        if package:config("media") then
            package:add("deps", "srtp")
        else
            package:add("defines", "RTC_ENABLE_MEDIA=0")
        end

        if package:config("capi_stdcall") then
            package:add("defines", "CAPI_STDCALL")
        end

        package:add("defines", "RTC_ENABLE_WEBSOCKET=" .. (package:config("websocket") and "1" or "0"))

        if not package:config("shared") then 
            package:add("defines", "RTC_STATIC")
        end 
    end)

    on_install(function (package)
        local configs = {
            "-DNO_EXAMPLES=ON",
            "-DNO_TESTS=ON",
            "-DWARNINGS_AS_ERRORS=OFF",
            "-DPREFER_SYSTEM_LIB=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        local openssl = package:dep("openssl3")
        if openssl and not openssl:is_system() then
            table.insert(configs, "-DOPENSSL_USE_STATIC_LIBS=" .. (not openssl:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DOPENSSL_ROOT_DIR=" .. openssl:installdir())
        end

        table.insert(configs, "-DUSE_GNUTLS=" .. (package:config("gnutls") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_MBEDTLS=" .. (package:config("mbedtls") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_NICE=" .. (package:config("nice") and "ON" or "OFF"))
        table.insert(configs, "-DNO_WEBSOCKET=" .. (not package:config("websocket") and "ON" or "OFF"))
        table.insert(configs, "-DNO_MEDIA=" .. (not package:config("media") and "ON" or "OFF"))
        table.insert(configs, "-DCAPI_STDCALL=" .. (package:config("capi_stdcall") and "ON" or "OFF"))
        table.insert(configs, "-DSCTP_DEBUG=" .. (package:config("sctp_debug") and "ON" or "OFF"))
        table.insert(configs, "-DRTC_UPDATE_VERSION_HEADER=" .. (package:config("rtc_update_version_header") and "ON" or "OFF"))

        import("package.tools.cmake").install(package, configs, {
            targets = {
                package:config("shared") and "datachannel" or "datachannel-static",
            }
        })
    end)

    on_test(function (package)
        assert(package:has_cfuncs("rtcSetUserPointer", {includes = "rtc/rtc.h"}))
    end)
