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

    on_load("windows", "mingw@macosx,linux", function (package)
        if not package:config("shared") then
            package:add("defines", "CURL_STATICLIB")
        end
    end)

    on_install("windows", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DCURL_DISABLE_LDAP=ON")
        table.insert(configs, "-DCMAKE_USE_SCHANNEL=ON")
        table.insert(configs, "-DCURL_STATIC_CRT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_install("macosx", "linux", "iphoneos", "mingw@macosx,linux", "cross", function (package)
        local configs = {"--disable-silent-rules", "--disable-dependency-tracking"}
        if package:debug() then
            table.insert(configs, "--enable-debug")
        else
            table.insert(configs, "--disable-debug")
        end
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
        else
            table.insert(configs, "--enable-shared=no")
        end
        if is_plat("macosx") then
            table.insert(configs, "--with-darwinssl")
            table.insert(configs, "--without-libidn2")
            table.insert(configs, "--without-nghttp2")
            table.insert(configs, "--without-brotli")
            table.insert(configs, "--without-zstd")
        end
        table.insert(configs, "--without-ca-bundle")
        table.insert(configs, "--without-ca-path")
        table.insert(configs, "--without-zlib")
        table.insert(configs, "--without-librtmp")
        table.insert(configs, "--disable-ares")
        table.insert(configs, "--disable-ldap")
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("curl_version", {includes = "curl/curl.h"}))
    end)
