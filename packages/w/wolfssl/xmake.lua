package("wolfssl")
    set_homepage("https://www.wolfssl.com")
    set_description("The wolfSSL library is a small, fast, portable implementation of TLS/SSL for embedded devices to the cloud.  wolfSSL supports up to TLS 1.3!")
    set_license("GPL-2.0")

    add_urls("https://github.com/wolfSSL/wolfssl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wolfSSL/wolfssl.git")
    add_versions("v5.3.0-stable", "1a3bb310dc01d3e73d9ad91b6ea8249d081016f8eef4ae8f21d3421f91ef1de9")

    add_configs("openssl_extra", {description = "WOLFSSL_OPENSSLEXTRA", default = "no", values = {"yes", "no"}})

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DWOLFSSL_OPENSSLEXTRA=" .. package:config("openssl_extra"))
        local ldflags
        if package:is_plat("android") then
            ldflags = "-llog"
        end
        import("package.tools.cmake").install(package, configs, {ldflags = ldflags})
    end)

    on_test(function (package)
        assert(package:has_cincludes("wolfssl/ssl.h"))
    end)
