package("libdatachannel")
    set_homepage("https://libdatachannel.org/")
    set_description("C/C++ WebRTC network library featuring Data Channels, Media Transport, and WebSockets")
    set_license("MPL-2.0")

    add_urls("https://github.com/paullouisageneau/libdatachannel/archive/refs/tags/$(version).tar.gz",
             "https://github.com/paullouisageneau/libdatachannel.git", {submodules = false})

    add_versions("v0.24.1", "e6fc363497a41b5dce38602937c12d30e5e536943cf09c5ee5671c8f206eee08")
    add_versions("v0.23.2", "b9606efc5b2b173f2d22d0be3f6ba4f12af78c00ca02cde5932f3ff902980eb9")
    add_versions("v0.23.1", "63e14d619ac4d9cc310a0c7620b80e6da88abf878f27ccc78cd099f95d47b121")

    add_configs("gnutls", {description = "Use GnuTLS instead of OpenSSL", default = false, type = "boolean", readonly = true})
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
    add_deps("plog", "usrsctp")
    add_deps("nlohmann_json", {configs = {cmake = true}})

    on_check("wasm", function (target)
        raise("package(libdatachannel) dep(usrsctp) unsupported wasm platform")
    end)

    on_check("android", function (package)
        local ndk = package:toolchain("ndk")
        local ndk_sdkver = ndk:config("ndk_sdkver")
        assert(ndk_sdkver and tonumber(ndk_sdkver) > 23, "package(libdatachannel) dep(usrsctp) need ndk api level > 23")
    end)

    on_load(function (package)
        if package:config("mbedtls") then
            raise("Unsupported now, build failed with `src/impl/dtlstransport.cpp:373:7: error: 'mbedtls_ssl_srtp_profile' does not name a type; did you mean 'mbedtls_x509_crt_profile'?`")
            package:add("deps", "mbedtls")
        elseif package:config("gnutls") then
            package:add("deps", "gnutls")
        else
            package:add("deps", "openssl3")
        end

        if package:config("nice") then
            package:add("deps", "libnice")
        else
            package:add("deps", "libjuice")
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

    on_install("!mingw", function (package)
        io.replace("CMakeLists.txt", "set(CMAKE_POSITION_INDEPENDENT_CODE ON)", "", {plain = true})
        -- add -DJUICE_STATIC from config mode 
        io.replace("CMakeLists.txt", "find_package(LibJuice REQUIRED)", "find_package(LibJuice CONFIG REQUIRED)", {plain = true})
        -- Error evaluating generator expression: $<TARGET_PDB_FILE:datachannel>
        -- TARGET_PDB_FILE is allowed only for targets with linker created artifacts.
        if package:is_plat("windows") then
            io.replace("CMakeLists.txt", "if(MSVC)\n\tinstall", "if(0)\ninstall", {plain = true})
        end

        local configs = {
            "-DNO_EXAMPLES=ON",
            "-DNO_TESTS=ON",
            "-DWARNINGS_AS_ERRORS=OFF",
            "-DPREFER_SYSTEM_LIB=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
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
