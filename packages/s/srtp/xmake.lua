package("srtp")

    set_homepage("https://github.com/cisco/libsrtp")
    set_description("Library for SRTP (Secure Realtime Transport Protocol)")

    add_urls("https://github.com/cisco/libsrtp.git")
    add_versions("v2.5.0", "a566a9cfcd619e8327784aa7cff4a1276dc1e895")

    add_configs("openssl", {description = "Enable OpenSSL crypto engine", default = false, type = "boolean"})
    add_configs("mbedtls", {description = "Enable MbedTLS crypto engine", default = false, type = "boolean"})
    add_configs("nss", {description = "Enable NSS crypto engine", default = false, type = "boolean"})
    
    add_deps("cmake")
    add_deps("openssl")

    on_install(function (package)
        local options = {
            openssl = "ENABLE_OPENSSL",
            mbedtls = "ENABLE_MBEDTLS",
            nss = "ENABLE_NSS"
        }
        local configs = {"-DLIBSRTP_TEST_APPS=OFF", "-DBUILD_WITH_WARNINGS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        for name, item in pairs(options) do
            table.insert(configs, "-D" .. item .. "=" .. (package:config(name) and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("srtp_init", {includes = "srtp2/srtp.h"}))
    end)

