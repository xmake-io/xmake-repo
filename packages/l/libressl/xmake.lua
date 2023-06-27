package("libressl")

    set_homepage("https://www.libressl.org/")
    set_description("LibreSSL is a version of the TLS/crypto stack forked from OpenSSL in 2014, with goals of modernizing the codebase, improving security, and applying best practice development processes.")

    add_urls("https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-$(version).tar.gz")
    add_versions("3.4.2", "cb82ca7d547336917352fbd23db2fc483c6c44d35157b32780214ec74197b3ce")
    add_versions("3.7.3", "7948c856a90c825bd7268b6f85674a8dcd254bae42e221781b24e3f8dc335db3")

    if is_plat("windows") then
        add_deps("cmake")
        add_syslinks("ws2_32", "bcrypt")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end
    on_install("windows", function (package)
        local configs = {"-DLIBRESSL_TESTS=OFF", "-DLIBRESSL_APPS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_STATIC_MSVC_RUNTIMES=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_install("macosx", "linux", "bsd", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SSL_new", {includes = "openssl/ssl.h"}))
    end)
