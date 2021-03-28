package("httplib")

    set_homepage("https://github.com/yhirose/cpp-httplib")
    set_description("A C++11 single-file header-only cross platform HTTP/HTTPS library.")

    set_urls("https://github.com/yhirose/cpp-httplib/archive/v$(version).zip",
             "https://github.com/yhirose/cpp-httplib.git")
    add_versions("0.8.5", "57d2a7e67ae6944292cd08cb16083463a93c7c139f6698560e872ade63b9b463")

    add_configs("ssl",  { description = "Requires OpenSSL", default = false, type = "boolean"})
    add_configs("zlib",  { description = "Requires Zlib", default = false, type = "boolean"})
    add_configs("brotli",  { description = "Requires Brotli", default = false, type = "boolean"})

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

    add_deps("cmake")
    on_install(function (package)
        local configs = {}
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
