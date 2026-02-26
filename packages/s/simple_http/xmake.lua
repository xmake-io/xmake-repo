package("simple_http")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/fantasy-peak/simple_http")
    set_description("A header-only HTTP library that supports both HTTP/2 and HTTP/1, based on Beast, nghttp2, and Asio.")
    set_license("MIT")

    add_urls("https://github.com/fantasy-peak/simple_http/archive/refs/tags/$(version).tar.gz",
             "https://github.com/fantasy-peak/simple_http.git")

    add_versions("v0.5.0", "56be1a264382022f180a18ce318eb2d44c0dcda9a21e173dcce44d4074bc58f7")
    add_versions("v0.4.0", "1438a5037ed424ae98b1d9e60cf506d32eaf2d709f373f004b80d98278e044ea")
    add_versions("v0.3.0", "2ed94c4ed0b8ee5cb512cc95417725a8b37cf1071ee46b4eac4591db27ec9fd3")
    add_versions("v0.2.0", "1c2ab7c2be317f95e34bdbe6c753293495b6743828ec4115b5f3c383c8c95adc")

    add_deps("cmake")
    add_deps("boost", {configs = {cmake = false}})
    add_deps("nghttp2", "openssl")

    on_install("linux", "cross", "bsd", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            simple_http::Config cfg{.ip = "0.0.0.0",
                                    .port = 6666,
                                    .worker_num = 4,
                                    .concurrent_streams = 200};
            void test() {
                simple_http::HttpServer hs(cfg);
                hs.setHttpHandler("/hello", [](auto req, auto writer) -> boost::asio::awaitable<void> { co_return; });
                return;
            }
        ]]}, {configs = {languages = "c++20"}, includes = {"simple_http.h"}}))
    end)
