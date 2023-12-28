package("srtp")

    set_homepage("https://github.com/cisco/libsrtp")
    set_description("Library for SRTP (Secure Realtime Transport Protocol)")

    add_urls("https://github.com/cisco/libsrtp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cisco/libsrtp.git")
    add_versions("v2.5.0", "8a43ef8e9ae2b665292591af62aa1a4ae41e468b6d98d8258f91478735da4e09")

    add_configs("openssl", {description = "Enable OpenSSL crypto engine", default = false, type = "boolean"})
    add_configs("mbedtls", {description = "Enable MbedTLS crypto engine", default = false, type = "boolean"})
    add_configs("nss", {description = "Enable NSS crypto engine", default = false, type = "boolean"})
    
    add_deps("cmake")
    add_deps("openssl")

    on_install("windows", "linux", "macosx", "android", "cross", "bsd", "mingw", function (package)
        local configs = {"-DLIBSRTP_TEST_APPS=OFF", "-DTEST_APPS=OFF", "-DBUILD_WITH_WARNINGS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-DENABLE_" .. name:upper() .. "=" .. (enabled and "ON" or "OFF"))
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("srtp_init", {includes = "srtp2/srtp.h"}))
    end)

