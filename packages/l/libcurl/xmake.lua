includes(path.join(os.scriptdir(), "versions.lua"))

package("libcurl")

    set_homepage("https://curl.haxx.se/")
    set_description("The multiprotocol file transfer library.")

    set_urls("https://curl.haxx.se/download/curl-$(version).tar.bz2",
             "http://curl.mirror.anstey.ca/curl-$(version).tar.bz2")
    add_urls("https://github.com/curl/curl/releases/download/curl-$(version).tar.bz2",
             {version = function (version) return (version:gsub("%.", "_")) .. "/curl-" .. version end})
    add_versions_list()

    if is_plat("linux") then
        add_deps("openssl")
    elseif is_plat("windows") then
        add_deps("cmake")
    end

    if is_plat("macosx") then
        add_frameworks("Security", "CoreFoundation")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("windows", "mingw") then
        add_syslinks("advapi32", "crypt32", "winmm", "ws2_32")
    end

    add_configs("zlib",    { description = "Enable zlib compression library.", default = false, type = "boolean"})
    add_configs("zstd",    { description = "Enable zstd compression library.", default = false, type = "boolean"})
    add_configs("openssl", { description = "Enable openssl library.", default = false, type = "boolean"})

    on_load(function (package)
        if package:is_plat("windows", "mingw") then
            if not package:config("shared") then
                package:add("defines", "CURL_STATICLIB")
            end
        end
        local configdeps = {zlib    = "zlib",
                            openssl = "openssl",
                            zstd    = "zstd"}
        for name, dep in pairs(configdeps) do
            if package:config(name) then
                package:add("deps", dep)
            end
        end
    end)

    on_install("windows", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DCURL_DISABLE_LDAP=ON")
        table.insert(configs, "-DCMAKE_USE_SCHANNEL=ON")
        table.insert(configs, "-DCMAKE_USE_LIBSSH2=OFF")
        table.insert(configs, "-DCURL_STATIC_CRT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                if name == "openssl" then
                    table.insert(configs, "-DCMAKE_USE_" .. name:upper() .. (enabled and "=ON" or "=OFF"))
                else
                    if name == "zlib" and not enabled then
                        io.replace("CMakeLists.txt", "if(ZLIB_FOUND)", "if(OFF)", {palin = true}) -- disable zlib now
                    end
                    table.insert(configs, "-DCURL_" .. name:upper() .. (enabled and "=ON" or "=OFF"))
                end
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_install("macosx", "linux", "iphoneos", "mingw@macosx,linux", "cross", function (package)
        local configs = {"--disable-silent-rules", "--disable-dependency-tracking"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        if is_plat("macosx") then
            table.insert(configs, "--with-darwinssl")
        end
        table.insert(configs, "--without-libidn2")
        table.insert(configs, "--without-nghttp2")
        table.insert(configs, "--without-brotli")
        table.insert(configs, "--without-ca-path")
        table.insert(configs, "--without-librtmp")
        table.insert(configs, "--without-libpsl")
        table.insert(configs, "--disable-ares")
        table.insert(configs, "--disable-ldap")
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                if enabled then
                    table.insert(configs, "--with-" .. name)
                else
                    table.insert(configs, "--without-" .. name)
                end
            end
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("curl_version", {includes = "curl/curl.h"}))
    end)
