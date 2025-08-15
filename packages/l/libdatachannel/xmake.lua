package("libdatachannel")
    add_deps("cmake", "openssl")
    add_urls("https://github.com/paullouisageneau/libdatachannel.git", {submodules = true})
    add_versions("v0.23.1", "222529eb2c8ae44f96462504ae38023f62809cec")

    add_configs("use_gnutls", {description = "Use GnuTLS instead of OpenSSL", default = false, type = "boolean"})
    add_configs("use_mbedtls", {description = "Use Mbed TLS instead of OpenSSL", default = false, type = "boolean"})
    add_configs("use_nice", {description = "Use libnice instead of libjuice", default = false, type = "boolean"})
    add_configs("prefer_system_lib", {description = "Prefer system libraries over submodules", default = false, type = "boolean"})
    add_configs("use_system_srtp", {description = "Use system libSRTP", default = false, type = "boolean"})
    add_configs("use_system_juice", {description = "Use system libjuice", default = false, type = "boolean"})
    add_configs("use_system_usrsctp", {description = "Use system libusrsctp", default = false, type = "boolean"})
    add_configs("use_system_plog", {description = "Use system Plog", default = false, type = "boolean"})
    add_configs("use_system_json", {description = "Use system Nlohmann JSON", default = false, type = "boolean"})
    add_configs("no_websocket", {description = "Disable WebSocket support", default = false, type = "boolean"})
    add_configs("no_media", {description = "Disable media transport support", default = false, type = "boolean"})
    add_configs("no_examples", {description = "Disable examples", default = false, type = "boolean"})
    add_configs("no_tests", {description = "Disable tests build", default = false, type = "boolean"})
    add_configs("warnings_as_errors", {description = "Treat warnings as errors", default = false, type = "boolean"})
    add_configs("capi_stdcall", {description = "Set calling convention of C API callbacks stdcall", default = false, type = "boolean"})
    add_configs("sctp_debug", {description = "Enable SCTP debugging output to verbose log", default = false, type = "boolean"})
    add_configs("rtc_update_version_header", {description = "Enable updating the version header", default = false, type = "boolean"})


    on_install(function (package)
         if package:is_plat("windows") and not package:config("shared") then 
            package:add("defines", "RTC_STATIC") 
        end 

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))

        table.insert(configs, "-DUSE_GNUTLS=" .. (package:config("use_gnutls") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_MBEDTLS=" .. (package:config("use_mbedtls") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_NICE=" .. (package:config("use_nice") and "ON" or "OFF"))
        table.insert(configs, "-DPREFER_SYSTEM_LIB=" .. (package:config("prefer_system_lib") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_SYSTEM_SRTP=" .. (package:config("use_system_srtp") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_SYSTEM_JUICE=" .. (package:config("use_system_juice") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_SYSTEM_USRSCTP=" .. (package:config("use_system_usrsctp") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_SYSTEM_PLOG=" .. (package:config("use_system_plog") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_SYSTEM_JSON=" .. (package:config("use_system_json") and "ON" or "OFF"))
        table.insert(configs, "-DNO_WEBSOCKET=" .. (package:config("no_websocket") and "ON" or "OFF"))
        table.insert(configs, "-DNO_MEDIA=" .. (package:config("no_media") and "ON" or "OFF"))
        table.insert(configs, "-DNO_EXAMPLES=" .. (package:config("no_examples") and "ON" or "OFF"))
        table.insert(configs, "-DNO_TESTS=" .. (package:config("no_tests") and "ON" or "OFF"))
        table.insert(configs, "-DWARNINGS_AS_ERRORS=" .. (package:config("warnings_as_errors") and "ON" or "OFF"))
        table.insert(configs, "-DCAPI_STDCALL=" .. (package:config("capi_stdcall") and "ON" or "OFF"))
        table.insert(configs, "-DSCTP_DEBUG=" .. (package:config("sctp_debug") and "ON" or "OFF"))
        table.insert(configs, "-DRTC_UPDATE_VERSION_HEADER=" .. (package:config("rtc_update_version_header") and "ON" or "OFF"))
        
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DOPENSSL_USE_STATIC_LIBS=ON")
        table.insert(configs, "-DNO_EXAMPLES=ON")
        import("package.tools.cmake").install(package, configs, {
            targets = {
                package:config("shared") and "datachannel" or "datachannel-static",
            }
        })
    end)
    on_test(function (package)
        assert(package:has_cfuncs("rtcSetUserPointer", {includes = "rtc/rtc.h"}))
    end)
package_end()
