package("libssh2")

    set_homepage("https://www.libssh2.org/")
    set_description("C library implementing the SSH2 protocol")
    set_license("BSD-3-Clause")

    set_urls("https://github.com/libssh2/libssh2/releases/download/libssh2-$(version)/libssh2-$(version).tar.gz",
             "https://www.libssh2.org/download/libssh2-$(version).tar.gz",
             "https://github.com/libssh2/libssh2.git")
    add_versions("1.10.0", "2d64e90f3ded394b91d3a2e774ca203a4179f69aebee03003e5a6fa621e41d51")
    add_versions("1.11.0", "3736161e41e2693324deb38c26cfdc3efe6209d634ba4258db1cecff6a5ad461")

    add_configs("backend", {description = "Select crypto backend.", default = (is_plat("windows") and "wincng" or "openssl"), type = "string", values = {"openssl", "wincng", "mbedtls", "libgcrypt"}})

    add_deps("zlib")
    if is_plat("windows") then
        add_deps("cmake")
        add_syslinks("bcrypt", "crypt32", "ws2_32")
    end

    on_load(function (package)
        if package:gitref() then
            package:add("deps", "automake", "autoconf")
        end
        local backend = package:config("backend")
        if backend ~= "wincng" then
            package:add("deps", backend)
        end
    end)

    on_install("windows", function (package)
        local configs = {"-DBUILD_TESTING=OFF",
                         "-DBUILD_EXAMPLES=OFF",
                         "-DENABLE_ZLIB_COMPRESSION=ON"}
        local backend_name = {wincng    = "WinCNG",
                              openssl   = "OpenSSL",
                              mbedtls   = "mbedTLS",
                              libgcrypt = "Libgcrypt"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCRYPTO_BACKEND=" .. backend_name[package:config("backend")])
        import("package.tools.cmake").install(package, configs)
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--disable-silent-rules",
                         "--disable-examples-build",
                         "--with-libz"}
        local lib_prefix = {openssl   = "libssl",
                            mbedtls   = "libmbedcrypto",
                            libgcrypt = "libgcrypt"}
        local backend = package:config("backend")
        table.insert(configs, "--with-crypto=" .. backend)
        local dep = package:dep(backend)
        if dep and not dep:is_system() then
            table.insert(configs, "--with-" .. lib_prefix[backend] .. "-prefix=" .. dep:installdir())
        end
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:is_plat("linux") and package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        if package:gitref() then
            os.vrunv("sh", {"./buildconf"})
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("libssh2_exit", {includes = "libssh2.h"}))
    end)
