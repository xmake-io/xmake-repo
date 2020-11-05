package("libcurl")

    set_homepage("https://curl.haxx.se/")
    set_description("The multiprotocol file transfer library.")

    set_urls("https://curl.haxx.se/download/curl-$(version).tar.bz2",
             "http://curl.mirror.anstey.ca/curl-$(version).tar.bz2")
    add_urls("https://github.com/curl/curl/releases/download/curl-$(version).tar.bz2",
             {version = function (version) return (version:gsub("%.", "_")) .. "/curl-" .. version end})

    add_versions("7.73.0", "cf34fe0b07b800f1c01a499a6e8b2af548f6d0e044dca4a29d88a4bee146d131")
    add_versions("7.72.0", "ad91970864102a59765e20ce16216efc9d6ad381471f7accceceab7d905703ef")
    add_versions("7.71.1", "9d52a4d80554f9b0d460ea2be5d7be99897a1a9f681ffafe739169afd6b4f224")
    add_versions("7.70.0", "a50bfe62ad67a24f8b12dd7fd655ac43a0f0299f86ec45b11354f25fbb5829d0")
    add_versions("7.69.1", "2ff5e5bd507adf6aa88ff4bbafd4c7af464867ffb688be93b9930717a56c4de8")
    add_versions("7.68.0", "207f54917dd6a2dc733065ccf18d61bb5bebeaceb5df49cd9445483e8623eeb9")
    add_versions("7.67.0", "dd5f6956821a548bf4b44f067a530ce9445cc8094fd3e7e3fc7854815858586c")
    add_versions("7.66.0", "6618234e0235c420a21f4cb4c2dd0badde76e6139668739085a70c4e2fe7a141")
    add_versions("7.65.3", "0a855e83be482d7bc9ea00e05bdb1551a44966076762f9650959179c89fce509")
    add_versions("7.64.1", "4cc7c738b35250d0680f29e93e0820c4cb40035f43514ea3ec8d60322d41a45d")

    if is_plat("linux") then
        add_deps("openssl")
    elseif is_plat("windows") then
        add_deps("cmake")
    end

    if is_plat("macosx") then
        add_frameworks("Security", "CoreFoundation")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install("windows", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_install("macosx", "linux", "iphoneos", function (package)
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
