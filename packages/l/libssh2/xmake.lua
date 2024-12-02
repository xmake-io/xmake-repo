package("libssh2")
    set_homepage("https://www.libssh2.org/")
    set_description("C library implementing the SSH2 protocol")
    set_license("BSD-3-Clause")

    set_urls("https://github.com/libssh2/libssh2/releases/download/libssh2-$(version)/libssh2-$(version).tar.gz",
             "https://www.libssh2.org/download/libssh2-$(version).tar.gz",
             "https://github.com/libssh2/libssh2.git")

    add_versions("1.11.1", "d9ec76cbe34db98eec3539fe2c899d26b0c837cb3eb466a56b0f109cabf658f7")
    add_versions("1.10.0", "2d64e90f3ded394b91d3a2e774ca203a4179f69aebee03003e5a6fa621e41d51")
    add_versions("1.11.0", "3736161e41e2693324deb38c26cfdc3efe6209d634ba4258db1cecff6a5ad461")

    add_configs("backend", {description = "Select crypto backend.", default = (is_plat("windows") and "wincng" or "openssl"), type = "string", values = {"openssl", "wincng", "mbedtls", "libgcrypt", "wolfssl"}})

    if is_plat("windows", "mingw") then
        add_syslinks("bcrypt", "crypt32", "ws2_32")
    end

    add_deps("cmake")
    add_deps("zlib")

    on_load(function (package)
        local backend = package:config("backend")
        if backend ~= "wincng" then
            package:add("deps", backend)
        end

        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "LIBSSH2_EXPORTS")
        end
    end)

    on_install("!wasm and !iphoneos", function (package)
        local configs = {
            "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW",
            "-DBUILD_TESTING=OFF",
            "-DBUILD_EXAMPLES=OFF",
            "-DENABLE_ZLIB_COMPRESSION=ON",
        }
        local backend_name = {
            wincng    = "WinCNG",
            openssl   = "OpenSSL",
            mbedtls   = "mbedTLS",
            libgcrypt = "Libgcrypt",
            wolfssl   = "wolfSSL",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DENABLE_DEBUG_LOGGING=" .. (package:is_debug() and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))

        local backend = package:config("backend")
        table.insert(configs, "-DCRYPTO_BACKEND=" .. backend_name[backend])

        if backend == "openssl" then
            local openssl = package:dep("openssl")
            if not openssl:is_system() then
                table.insert(configs, "-DOPENSSL_ROOT_DIR=" .. openssl:installdir())
            end
        end

        local opt = {}
        if package:is_plat("windows") then
            os.mkdir(path.join(package:buildir(), "src/pdb"))
            if backend == "mbedtls" then
                opt.packagedeps = backend
            end
        end
        import("package.tools.cmake").install(package, configs, opt)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.vcp(path.join(package:buildir(), "src/*.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("libssh2_exit", {includes = "libssh2.h"}))
    end)
