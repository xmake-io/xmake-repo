package("cpp-httplib")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/yhirose/cpp-httplib")
    set_description("A C++11 single-file header-only cross platform HTTP/HTTPS library.")
    set_license("MIT")

    set_urls("https://github.com/yhirose/cpp-httplib/archive/v$(version).tar.gz",
             "https://github.com/yhirose/cpp-httplib.git")

    add_versions("0.8.5", "b353f3e7c124a08940d9425aeb7206183fa29857a8f720c162f8fd820cc18f0e")
    add_versions("0.9.2", "bfef2587a2aa31c85fb361df71c720be97076f8083e4f3881da8572f6a58054f")
    add_versions("0.12.1", "0e56c25c63e730ebd42e2beda6e7cb1b950131d8fc00d3158b1443a8d76f41ca")
    add_versions("0.12.6", "24bc594a9efcc08a5a6f3928e848d046d411a88b07bcd6f7f3851227a1f0133e")
    add_versions("0.14.0", "3a92248ef8cf2c32ad07f910b8e3052ff2427022b2adb871cf326fb620d2438e")
    add_versions("0.14.1", "2d4fb5544da643e5d0a82585555d8b7502b4137eb321a4abbb075e21d2f00e96")
    add_versions("0.14.2", "dbcf5590e8ed35c6745c2ad659a5ebec92f05187d1506eec24449d6db95e5084")
    add_versions("0.14.3", "dcf6486d9030937636d8a4f820ca9531808fd7edb283893dddbaa05f99357e63")
    add_versions("0.15.0", "b658e625e283e2c81437a485a95f3acf8b1d32c53d8147b1ccecc8f630e1f7bb")
    add_versions("0.15.1", "8d6a4a40ee8fd3f553b7e895882e60e674bd910883fc1857587dbbabee3cdb91")
    add_versions("0.15.2", "4afbcf4203249d2cbcb698e46e1f6fb61b479013a84844d6bb1c044e233cab6a")
    add_versions("0.15.3", "2121bbf38871bb2aafb5f7f2b9b94705366170909f434428352187cb0216124e")

    add_configs("ssl",  { description = "Requires OpenSSL", default = false, type = "boolean"})
    add_configs("zlib",  { description = "Requires Zlib", default = false, type = "boolean"})
    add_configs("brotli",  { description = "Requires Brotli", default = false, type = "boolean"})
    add_configs("exceptions", {description = "Enable the use of C++ exceptions", default = true, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("ssl") then
            package:add("deps", "openssl" .. (package:version():ge("0.15.0") and "3" or ""))
            package:add("defines", "CPPHTTPLIB_OPENSSL_SUPPORT")
        end
        if package:config("zlib") then
            package:add("deps", "zlib")
            package:add("defines", "CPPHTTPLIB_ZLIB_SUPPORT")
        end
        if package:config("brotli") then
            package:add("deps", "brotli")
            package:add("defines", "CPPHTTPLIB_BROTLI_SUPPORT")
        end
    end)

    if on_check then
        on_check("android", function (package)
            import("core.tool.toolchain")
            local ndk = toolchain.load("ndk", {plat = package:plat(), arch = package:arch()})
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) >= 24, "package(httplib): need ndk api level >= 24 for android")
        end)
    end

    on_install(function (package)
        if package:is_plat("android") then
            import("core.tool.toolchain")
            local ndk = toolchain.load("ndk", {plat = package:plat(), arch = package:arch()})
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) >= 24, "package(httplib): need ndk api level >= 24 for android")
        end
        local configs = {"-DHTTPLIB_COMPILE=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DHTTPLIB_REQUIRE_OPENSSL=" .. (package:config("ssl") and "ON" or "OFF"))
        table.insert(configs, "-DHTTPLIB_REQUIRE_ZLIB=" .. (package:config("zlib") and "ON" or "OFF"))
        table.insert(configs, "-DHTTPLIB_REQUIRE_BROTLI=" .. (package:config("brotli") and "ON" or "OFF"))
        table.insert(configs, "-DHTTPLIB_NO_EXCEPTIONS=" .. (package:config("exceptions") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <httplib.h>
            static void test() {
                httplib::Client cli("http://cpp-httplib-server.yhirose.repl.co");
            }
        ]]}, {includes = "httplib.h",configs = {languages = "c++11"}}))
    end)
