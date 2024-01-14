includes(path.join(os.scriptdir(), "versions.lua"))

package("libcurl")
    set_homepage("https://curl.haxx.se/")
    set_description("The multiprotocol file transfer library.")
    set_license("MIT")

    set_urls("https://curl.haxx.se/download/curl-$(version).tar.bz2",
             "http://curl.mirror.anstey.ca/curl-$(version).tar.bz2")
    add_urls("https://github.com/curl/curl/releases/download/curl-$(version).tar.bz2",
             {version = function (version) return (version:gsub("%.", "_")) .. "/curl-" .. version end})
    add_versions_list()

    add_deps("cmake")

    if is_plat("macosx", "iphoneos") then
        add_frameworks("Security", "CoreFoundation", "SystemConfiguration")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("windows", "mingw") then
        add_syslinks("advapi32", "crypt32", "wldap32", "winmm", "ws2_32", "user32")
    end

    add_configs("cares",    {description = "Enable c-ares support.", default = false, type = "boolean"})
    add_configs("openssl",  {description = "Enable OpenSSL for SSL/TLS.", default = is_plat("linux", "android", "cross"), type = "boolean"})
    add_configs("mbedtls",  {description = "Enable mbedTLS for SSL/TLS.", default = false, type = "boolean"})
    add_configs("nghttp2",  {description = "Use Nghttp2 library.", default = false, type = "boolean"})
    add_configs("openldap", {description = "Use OpenLDAP library.", default = false, type = "boolean"})
    add_configs("libidn2",  {description = "Use Libidn2 for IDN support.", default = false, type = "boolean"})
    add_configs("zlib",     {description = "Enable zlib support.", default = false, type = "boolean"})
    add_configs("zstd",     {description = "Enable zstd support.", default = false, type = "boolean"})
    add_configs("brotli",   {description = "Enable brotli support.", default = false, type = "boolean"})
    add_configs("libssh2",  {description = "Use libSSH2 library.", default = false, type = "boolean"})
    add_configs("libpsl",   {description = "Use libpsl library.", default = false, type = "boolean"})

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::curl")
    elseif is_plat("linux") then
        add_extsources("pacman::curl", "apt::libcurl4-gnutls-dev", "apt::libcurl4-nss-dev", "apt::libcurl4-openssl-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::curl")
    end

    on_load(function (package)
        if package:is_plat("windows", "mingw") then
            if not package:config("shared") then
                package:add("defines", "CURL_STATICLIB")
            end
        end
        local configdeps = {cares    = "c-ares",
                            openssl  = "openssl",
                            mbedtls  = "mbedtls",
                            nghttp2  = "nghttp2",
                            openldap = "openldap",
                            libidn2  = "libidn2",
                            libpsl   = "libpsl",
                            zlib     = "zlib",
                            zstd     = "zstd",
                            brotli   = "brotli",
                            libssh2  = "libssh2"}
        local has_deps = false
        for name, dep in pairs(configdeps) do
            if package:config(name) then
                package:add("deps", dep)
                has_deps = true
            end
        end
        if has_deps and package:is_plat("linux", "macosx") then
            package:add("deps", "pkg-config")
        end
    end)

    on_install("windows", "mingw", "linux", "macosx", "android", "iphoneos", "cross", function (package)
        local version = package:version()

        local configs = {"-DBUILD_TESTING=OFF", "-DENABLE_MANUAL=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        if (package:is_plat("mingw") and version:ge("7.85")) then
            package:add("syslinks", "bcrypt")
        end

        local configopts = {cares    = "ENABLE_ARES",
                            openssl  = (version:ge("7.81") and "CURL_USE_OPENSSL" or "CMAKE_USE_OPENSSL"),
                            mbedtls  = (version:ge("7.81") and "CURL_USE_MBEDTLS" or "CMAKE_USE_MBEDTLS"),
                            nghttp2  = "USE_NGHTTP2",
                            libidn2  = "USE_LIBIDN2",
                            zlib     = "CURL_ZLIB",
                            zstd     = "CURL_ZSTD",
                            brotli   = "CURL_BROTLI",
                            libssh2  = (version:ge("7.81") and "CURL_USE_LIBSSH2" or "CMAKE_USE_LIBSSH2"),
                            libpsl   = "CURL_USE_LIBPSL"}
        for name, opt in pairs(configopts) do
            table.insert(configs, "-D" .. opt .. "=" .. (package:config(name) and "ON" or "OFF"))
        end
        if not package:config("openldap") then
            table.insert(configs, "-DCURL_DISABLE_LDAP=ON")
        end
        if package:config("openssl") then
            local openssl = package:dep("openssl")
            if openssl and not openssl:is_system() then
                table.insert(configs, "-DOPENSSL_ROOT_DIR=" .. openssl:installdir())
            end
        end
        if package:is_plat("windows", "mingw") then
            table.insert(configs, (version:ge("7.80") and "-DCURL_USE_SCHANNEL=ON" or "-DCMAKE_USE_SCHANNEL=ON"))
        end
        if package:is_plat("macosx", "iphoneos") then
            table.insert(configs, (version:ge("7.65") and "-DCURL_USE_SECTRANSP=ON" or "-DCMAKE_USE_DARWINSSL=ON"))
        end
        if package:is_plat("windows") then
            table.insert(configs, "-DCURL_STATIC_CRT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        if package:is_plat("mingw") and version:le("7.85.0") then
            io.replace("src/CMakeLists.txt", 'COMMAND ${CMAKE_COMMAND} -E echo "/* built-in manual is disabled, blank function */" > tool_hugehelp.c', "", {plain = true})
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("curl_version", {includes = "curl/curl.h"}))
    end)
