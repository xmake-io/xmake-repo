package("simple_http")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/fantasy-peak/simple_http")
    set_description("A c++20 header-only HTTP library that supports both HTTP/2 and HTTP/1, based on Beast, nghttp2, and Asio.")
    set_license("MIT")

    add_urls("https://github.com/fantasy-peak/simple_http/archive/refs/tags/$(version).tar.gz",
             "https://github.com/fantasy-peak/simple_http.git")

    add_versions("v0.6.7", "d22f7c543d68830b421fa70154ce348cb897ac5494fc50691e2045bf330587c5")
    add_versions("v0.6.6", "f0fcd565ab8d14ec3dcd7af8e832ac16befcb097e39332927d3c896bf5c212b4")
    add_versions("v0.6.5", "e8afa5a4b6e1acfb3f23e9917c7a36591f2b32a482a22a7ec37e1e020284fbf3")
    add_versions("v0.6.4", "3e25e23ba6473a4cd51357abc4995b68722b3deb3c043897c509913810e1818b")
    add_versions("v0.6.3", "9b80b0329dbb6e042b46844f1ab6255c1bb3108f0b1e2082704f853b50bc75bc")
    add_versions("v0.6.2", "ffe93846c583a9951c209550101486e2437c123b095c8b00dbed3b9bb594abc9")
    add_versions("v0.6.1", "1772bf750adb04e430b4275385b6d65230830181b93574dba178a854526247ff")
    add_versions("v0.6.0", "6d4649184b4023d2dc45d253a44a6296d14e86999e424c846da8c17211f827ed")
    add_versions("v0.5.0", "56be1a264382022f180a18ce318eb2d44c0dcda9a21e173dcce44d4074bc58f7")
    add_versions("v0.4.0", "1438a5037ed424ae98b1d9e60cf506d32eaf2d709f373f004b80d98278e044ea")
    add_versions("v0.3.0", "2ed94c4ed0b8ee5cb512cc95417725a8b37cf1071ee46b4eac4591db27ec9fd3")
    add_versions("v0.2.0", "1c2ab7c2be317f95e34bdbe6c753293495b6743828ec4115b5f3c383c8c95adc")

    add_configs("openssl3", {description = "default use openssl3", default = true, type = "boolean"})

    add_deps("cmake")
    add_deps("boost", {configs = {asio = true, regex = true}})
    add_deps("nghttp2")

    on_load(function (package)
        if package:is_plat("mingw") then
            package:add("syslinks", "mswsock", "ws2_32")
            package:add("cxflags", "-Wa,-mbig-obj")
            package:add("asflags", "-mbig-obj")
        end
        if package:config("openssl3") then
            package:add("deps", "openssl3")
        else
            package:add("deps", "openssl")
        end
    end)

    on_install("linux", "cross", "bsd", "mingw", function (package)
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
