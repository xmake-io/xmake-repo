package("cpp-httplib")

    set_homepage("https://github.com/yhirose/cpp-httplib")
    set_description("A C++11 single-file header-only cross platform HTTP/HTTPS library.")

    set_urls("https://github.com/yhirose/cpp-httplib/archive/v$(version).zip",
             "https://github.com/yhirose/cpp-httplib.git")
    add_versions("0.8.5", "57d2a7e67ae6944292cd08cb16083463a93c7c139f6698560e872ade63b9b463")
    add_versions("0.9.2", "87131d53c14b921ca1a4fae0d5d4081c218dd18004b768a8069de29b130ab6bc")
    add_versions("0.12.1", "bd2e98842208df1c6c19f5446b7b0fe8f094ad7c931db0fefe52055c496c9d13")
    add_versions("0.12.6", "bdeb6be5f30cce0544204ed50bcb9b15ca0f9b360c148cbf75f0664584ac92d9")

    add_configs("ssl",  { description = "Requires OpenSSL", default = false, type = "boolean"})
    add_configs("zlib",  { description = "Requires Zlib", default = false, type = "boolean"})
    add_configs("brotli",  { description = "Requires Brotli", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("ssl") then
            package:add("deps", "openssl")
        end
        if package:config("zlib") then
            package:add("deps", "zlib")
        end
        if package:config("brotli") then
            package:add("deps", "brotli")
        end
    end)

    on_install(function (package)
        if package:is_plat("android") then
            import("core.tool.toolchain")
            local ndk = toolchain.load("ndk", {plat = package:plat(), arch = package:arch()})
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) >= 24, "package(httplib): need ndk api level >= 24 for android")
        end
        local configs = {}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DHTTPLIB_REQUIRE_OPENSSL=" .. (package:config("ssl") and "ON" or "OFF"))
        table.insert(configs, "-DHTTPLIB_REQUIRE_ZLIB=" .. (package:config("zlib") and "ON" or "OFF"))
        table.insert(configs, "-DHTTPLIB_REQUIRE_BROTLI=" .. (package:config("brotli") and "ON" or "OFF"))
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
