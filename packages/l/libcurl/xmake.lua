package("libcurl")

    set_homepage("https://curl.haxx.se/")
    set_description("The multiprotocol file transfer library.")

    set_urls("https://curl.haxx.se/download/curl-$(version).tar.bz2",
             "http://curl.mirror.anstey.ca/curl-$(version).tar.bz2",
             "https://github.com/curl/curl/releases/download/curl-7_64_1/curl-$(version).tar.bz2")
    add_versions("7.64.1", "4cc7c738b35250d0680f29e93e0820c4cb40035f43514ea3ec8d60322d41a45d")
 
    if is_plat("linux") then
        add_deps("openssl")
    elseif is_plat("windows") then
        add_deps("cmake")
    end

    if is_plat("macosx") then
        add_frameworks("Security")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end
 
    on_install("windows", function (package)
        local configs = {}
        import("package.tools.cmake").install(package, configs)
    end)

    on_install("macosx", "linux", "iphoneos", function (package)
        local configs = {"--disable-silent-rules", "--disable-dependency-tracking", "--enable-shared=no"}
        if package:debug() then
            table.insert(configs, "--enable-debug")
        else
            table.insert(configs, "--disable-debug")
        end
        if is_plat("macosx") then
            table.insert(configs, "--with-darwinssl")
        end
        table.insert(configs, "--without-ca-bundle")
        table.insert(configs, "--without-ca-path")
        table.insert(configs, "--without-zlib")
        table.insert(configs, "--disable-ares")
        table.insert(configs, "--disable-ldap")
        import("package.tools.autoconf").install(package, configs) 
    end)

    on_test(function (package)
        assert(package:has_cfuncs("curl_version", {includes = "curl/curl.h"}))
    end)
