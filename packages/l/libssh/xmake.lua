package("libssh")
    set_homepage("https://www.libssh2.org/")
    set_description("C library implementing the SSH2 protocol")
    set_license("BSD-3-Clause")

    add_urls("https://git.libssh.org/projects/libssh.git",
             "https://gitlab.com/libssh/libssh-mirror.git")

    add_urls("https://gitlab.com/libssh/libssh-mirror/-/archive/libssh-$(version)/libssh-mirror-libssh-$(version).tar.bz2", {alias = "gitlab"})
    add_urls("https://www.libssh.org/files/$(version).tar.xz", {
        alias = "home",
        version = function (version)
            return format("%d.%d/libssh-%s", version:major(), version:minor(), version)
        end
    })

    add_versions("home:0.11.1", "14b7dcc72e91e08151c58b981a7b570ab2663f630e7d2837645d5a9c612c1b79")

    add_versions("gitlab:0.11.1", "7d0d064b7d44420036f410d4dd3f05ad6ada61d21314d1e9d424a2e9970d1b68")

    add_configs("zlib", {description = "Build with zlib", default = false, type = "boolean"})
    add_configs("backend", {description = "Select crypto backend.", default = (is_plat("wasm", "iphoneos") and "mbedtls" or "openssl"), type = "string", values = {"openssl", "mbedtls", "libgcrypt"}})

    if is_plat("windows", "mingw") then
        add_syslinks("iphlpapi", "shell32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("zlib") then
            package:add("deps", "zlib")
        end
        package:add("deps", package:config("backend"))

        if package:is_plat("windows", "mingw") and not package:config("shared") then
            package:add("defines", "LIBSSH_STATIC")
        end
    end)

    on_install("!android", function (package)
        io.replace("src/CMakeLists.txt", "iphlpapi", "iphlpapi\ncrypt32", {plain = true})

        local configs = {
            "-DWITH_EXAMPLES=OFF",
            "-DWITH_GSSAPI=OFF",
            "-DWITH_NACL=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        local backend = package:config("backend")
        table.insert(configs, "-DWITH_ZLIB=" .. (package:config("zlib") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_MBEDTLS=" .. (backend == "mbedtls" and "ON" or "OFF"))
        table.insert(configs, "-DWITH_GCRYPT=" .. (backend == "libgcrypt" and "ON" or "OFF"))

        local openssl = package:dep("openssl")
        if openssl then
            if not openssl:is_system() then
                table.insert(configs, "-DOPENSSL_ROOT_DIR=" .. openssl:installdir())
            end
        end

        if package:is_plat("windows") then
            os.mkdir(path.join(package:buildir(), "src/pdb"))
        end
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.vcp(path.join(package:buildir(), "src/*.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ssh_init", {includes = "libssh/libssh.h"}))
    end)
