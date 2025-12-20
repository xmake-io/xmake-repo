package("sioclient")
    set_homepage("https://github.com/socketio/socket.io-client-cpp")
    set_description("C++11 implementation of Socket.IO client")
    set_license("MIT")

    add_urls("https://github.com/socketio/socket.io-client-cpp/archive/refs/tags/$(version).tar.gz")

    add_versions("3.1.0","f54dd36b8e5618d028c7c42f0c1a83a0d3a58f9239cf4b770f6b02b925909597")
    add_versions("3.0.0","6c11383eaea837d3dc4183d31f8d27f5ce08b3987f4903708983044115ebd95a")
    add_versions("2.1.0","f5bd6260403dd6c62c6dbf97ca848f5db69908edbdc0a365e28be06cdd2a44f8")

    add_deps("rapidjson")
    add_deps("websocketpp")
    add_deps("asio")
    add_deps("openssl3")

    on_install(function (package)
        local ver = package:version_str()

        local content = string.format([[
            add_rules("mode.debug", "mode.release")

            add_requires("rapidjson")
            add_requires("websocketpp")
            add_requires("asio")
            add_requires("openssl3")

            target("sioclient")
                set_kind("$(kind)")
                set_languages("cxx11")
                add_files("src/*.cpp")
                add_files("src/internal/*.cpp")
                add_headerfiles("src/internal/*.h")
                add_headerfiles("src/*.h")
                add_packages("rapidjson", "websocketpp", "asio", "openssl3")
                add_defines("VERSION=%s")
        ]], ver)

        io.writefile("xmake.lua", content)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                sio::client h;
                h.socket();
            }
        ]]}, {includes = {"sio_client.h"}, configs = {languages = "cxx11"}}))
    end)