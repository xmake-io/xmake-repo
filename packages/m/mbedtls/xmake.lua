package("mbedtls")

    set_homepage("https://tls.mbed.org")
    set_description("An SSL library")

    set_urls("https://github.com/ARMmbed/mbedtls/archive/mbedtls-$(version).zip")

    add_versions("3.4.0", "c08c47c6cf038529cafde819fe06e26e648fcc08969e21f9422a640f40435246")
    add_versions("2.25.0", "c2aad438a022c8b0349c9c4ce4a0b40d5df26fe6c63b0c85012b739f279aaf56")
    add_versions("2.13.0", "6e747350bc13e8ff51799daa50f74230c6cd8e15977da55dd59f57b23dcf70a6")
    add_versions("2.7.6", "e527d828ab82650102ca8031302e5d4bc68ea887b2d84e43d3da2a80a9e5a2c8")

    add_deps("cmake")

    add_links("mbedtls", "mbedx509", "mbedcrypto")

    on_install(function (package)
        local configs = {"-DENABLE_TESTING=OFF", "-DENABLE_PROGRAMS=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mbedtls_ssl_init", {includes = "mbedtls/ssl.h"}))
    end)

