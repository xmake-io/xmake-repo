package("simple_http")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/fantasy-peak/simple_http")
    set_description("A header-only HTTP library that supports both HTTP/2 and HTTP/1, based on Beast, nghttp2, and Asio.")
    set_license("MIT")

    add_urls("https://github.com/fantasy-peak/simple_http/archive/refs/tags/$(version).tar.gz",
             "https://github.com/fantasy-peak/simple_http.git")

    add_versions("v0.1.0", "4e5b92e5f08e515437d30627c57356c69b73e38e68df57d4d9bfd0a9cc91cc2a")

    add_deps("cmake")
    add_deps("boost", {configs = {cmake = false}})
    add_deps("nghttp2", "openssl")

    on_install("linux", "cross", "bsd", "macosx", function (package)
        if package:is_plat("macosx") then
            io.replace("include/simple_http.h", "iv.emplace_back(NGHTTP2_", "iv.push_back({NGHTTP2_", {plain = true})
            io.replace("include/simple_http.h", "cfg.concurrent_streams);", "cfg.concurrent_streams});", {plain = true})
            io.replace("include/simple_http.h", "cfg.window_size.value());", "cfg.window_size.value()});", {plain = true})
            io.replace("include/simple_http.h", "cfg.max_frame_size.value());", "cfg.max_frame_size.value()});", {plain = true})
        end
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
                hs.setHttpHandler(
                    "/hello", [](auto req, auto writer) -> boost::asio::awaitable<void> {
                });
                return;
            }
        ]]}, {configs = {languages = "c++20"}, includes = {"simple_http.h"}}))
    end)
