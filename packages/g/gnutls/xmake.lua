package("gnutls")
    set_homepage("https://www.gnutls.org/")
    set_description("GnuTLS is a secure communications library implementing the SSL, TLS and DTLS protocols and technologies around them.")
    set_license("LGPL-2.1")

    add_urls("https://www.gnupg.org/ftp/gcrypt/gnutls/v3.8/gnutls-$(version).tar.xz")
    add_versions("3.8.9", "69e113d802d1670c4d5ac1b99040b1f2d5c7c05daec5003813c049b5184820ed")

    if is_plat("mingw") then
        add_syslinks("ws2_32", "crypt32", "bcrypt", "ncrypt")
    end

    add_links("gnutls-openssl", "gnutlsxx", "gnutls")

    add_deps("pkg-config")
    add_deps("p11-kit")

    on_load(function (package)
        package:add("deps", "nettle", "libtasn1", "libidn2", "gmp", "libunistring", "brotli", "zlib", "zstd", { configs = {shared = package:config("shared")} })
    end)

    on_install("linux", "mingw", "cross", function (package)
        local configs = {"--disable-tests", "--disable-doc", "--disable-nls",
                        "--with-tpm2=no",
                        "--with-idn",
                        "--with-brotli",
                        "--with-zstd",
                        "--enable-openssl-compatibility",
                        "--with-default-trust-store-pkcs11=pkcs11:",
                        }
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs, {packagedeps = {"nettle", "p11-kit", "libtasn1", "libidn2", "gmp", "libunistring", "brotli", "zlib", "zstd"}})
    end)

    on_test(function (package)
        assert(package:check_csnippets([[
            #include <gnutls/gnutls.h>
            void test(void) {
                gnutls_session_t session;
                gnutls_global_deinit();
            }
        ]]))
    end)
