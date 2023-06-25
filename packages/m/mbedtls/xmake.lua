package("mbedtls")
    set_homepage("https://tls.mbed.org")
    set_description("An SSL library")
    set_license("Apache-2.0")

    add_urls("https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/$(version).zip", {version = function (version)
        return version:ge("v2.23.0") and version or ("mbedtls-" .. tostring(version):sub(2))
    end})
    add_urls("https://github.com/Mbed-TLS/mbedtls.git")

    add_versions("v3.4.0", "9969088c86eb89f6f0a131e699c46ff57058288410f2087bd0d308f65e9fccb5")
    add_versions("v2.28.3", "0c0abbd6e33566c5c3c15af4fc19466c8edb62fa483d4ce98f1ba3f656656d2d")
    add_versions("v2.25.0", "6bf01ef178925f7db3c9027344a50855b116f2defe4a24cbdc0220111a371597")
    add_versions("v2.13.0", "6e747350bc13e8ff51799daa50f74230c6cd8e15977da55dd59f57b23dcf70a6")
    add_versions("v2.7.6", "e527d828ab82650102ca8031302e5d4bc68ea887b2d84e43d3da2a80a9e5a2c8")

    add_deps("cmake")

    add_links("mbedtls", "mbedx509", "mbedcrypto")

    if is_plat("windows") then
        add_syslinks("advapi32")
    end

    on_install(function (package)
        local configs = {"-DENABLE_TESTING=OFF", "-DENABLE_PROGRAMS=OFF", "-DMBEDTLS_FATAL_WARNINGS=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mbedtls_ssl_init", {includes = "mbedtls/ssl.h"}))
    end)

