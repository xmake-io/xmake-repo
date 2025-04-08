package("websocketpp")
    set_kind("library", {headeronly = true})
    set_homepage("http://www.zaphoyd.com/websocketpp")
    set_description("C++ websocket client/server library")

    add_urls("https://github.com/zaphoyd/websocketpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zaphoyd/websocketpp.git")
    add_versions("0.8.2", "6ce889d85ecdc2d8fa07408d6787e7352510750daa66b5ad44aacb47bea76755")

    -- Compatibility fixes for Boost 1.87 Reference to PR https://github.com/zaphoyd/websocketpp/pull/1164
    --add_patches("0.8.2", [[https://github.com/zaphoyd/websocketpp/compare/0.8.2%2E%2E%2Eamini-allight%3Awebsocketpp%3Adevelop.diff]], "1d50646a00452155443f401a4b88b8b16047f3218cbe0a33a6947e92d094a13c")

    add_deps("cmake")
    add_deps("boost") --, {configs = {system = true, asio = true, regex = true}}

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <websocketpp/config/asio_no_tls.hpp>
            #include <websocketpp/server.hpp>
            typedef websocketpp::server<websocketpp::config::asio> server;
            void test() {
                server echo_server;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
