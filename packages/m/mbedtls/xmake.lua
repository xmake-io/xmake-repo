package("mbedtls")
    set_homepage("https://tls.mbed.org")
    set_description("An open source, portable, easy to use, readable and flexible TLS library, and reference implementation of the PSA Cryptography API")
    set_license("Apache-2.0")

    add_urls("https://github.com/Mbed-TLS/mbedtls/releases/download/$(version).tar.bz2", {version = function (version)
        return string.format("%s/mbedtls-%s", version, tostring(version):sub(2))
    end})
    add_urls("https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/$(version).zip", {version = function (version)
        return version:ge("v2.23.0") and version or ("mbedtls-" .. tostring(version):sub(2))
    end})
    add_urls("https://github.com/Mbed-TLS/mbedtls.git")

    add_versions("v3.6.0", "3ecf94fcfdaacafb757786a01b7538a61750ebd85c4b024f56ff8ba1490fcd38")
    add_versions("v3.5.1", "959a492721ba036afc21f04d1836d874f93ac124cf47cf62c9bcd3a753e49bdb")
    add_versions("v3.4.0", "9969088c86eb89f6f0a131e699c46ff57058288410f2087bd0d308f65e9fccb5")
    add_versions("v2.28.3", "0c0abbd6e33566c5c3c15af4fc19466c8edb62fa483d4ce98f1ba3f656656d2d")
    add_versions("v2.25.0", "6bf01ef178925f7db3c9027344a50855b116f2defe4a24cbdc0220111a371597")
    add_versions("v2.13.0", "6e747350bc13e8ff51799daa50f74230c6cd8e15977da55dd59f57b23dcf70a6")
    add_versions("v2.7.6", "e527d828ab82650102ca8031302e5d4bc68ea887b2d84e43d3da2a80a9e5a2c8")

    add_patches("3.5.1", path.join(os.scriptdir(), "patches", "3.5.1", "aesni-mingw-i386.patch"), "4b5c5de69930049242cc1d6a84185881a936a27773ecaf975290ac591f38a41d")

    add_deps("cmake")

    add_links("mbedtls", "mbedx509", "mbedcrypto")

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "advapi32", "bcrypt")
    end

    on_install("windows|x86", "windows|x64", "linux", "macosx", "bsd", "mingw", "android", "iphoneos", "cross", "wasm", function (package)
        local configs = {"-DENABLE_TESTING=OFF", "-DENABLE_PROGRAMS=OFF", "-DMBEDTLS_FATAL_WARNINGS=OFF"}
        if package:config("shared") then
            table.insert(configs, "-DUSE_SHARED_MBEDTLS_LIBRARY=ON")
            table.insert(configs, "-DUSE_STATIC_MBEDTLS_LIBRARY=OFF")
            if package:is_plat("windows") then
                table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
                io.replace("library/constant_time_impl.h", "extern volatile", "__declspec(dllimport) volatile", {plain = true})
                io.replace("include/mbedtls/x509_crt.h", "extern const mbedtls_x509_crt_profile mbedtls_x509_crt_profile_suiteb;", "__declspec(dllimport) const mbedtls_x509_crt_profile mbedtls_x509_crt_profile_suiteb;", {plain = true})
                io.replace("include/mbedtls/x509_crt.h", "extern const mbedtls_x509_crt_profile mbedtls_x509_crt_profile_default;", "__declspec(dllimport) const mbedtls_x509_crt_profile mbedtls_x509_crt_profile_default;", {plain = true})
                io.replace("library/psa_util_internal.h", "extern const mbedtls_error_pair_t psa_to_ssl_errors[7];", "__declspec(dllimport) const mbedtls_error_pair_t psa_to_ssl_errors[7];", {plain = true})
            end
        else
            table.insert(configs, "-DUSE_SHARED_MBEDTLS_LIBRARY=OFF")
            table.insert(configs, "-DUSE_STATIC_MBEDTLS_LIBRARY=ON")
        end
        local cxflags
        if package:is_plat("mingw") and package:is_arch("i386") then
            cxflags = {"-maes", "-msse2", "-mpclmul"}
        end
        import("package.tools.cmake").install(package, configs, {cxflags = cxflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mbedtls_ssl_init", {includes = "mbedtls/ssl.h"}))
        assert(package:check_cxxsnippets({test = [[
            void test() {
                mbedtls_aes_context ctx;

                unsigned char key[32]; 
                mbedtls_aes_setkey_enc(&ctx, key, 256);
            }
        ]]}, {includes = "mbedtls/aes.h"}))
    end)
