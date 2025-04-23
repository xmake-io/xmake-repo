package("socket-io-client")
    set_homepage("https://github.com/socketio/socket.io-client-cpp")
    set_description("C++11 implementation of Socket.IO client")
    set_license("MIT")

    add_urls("https://github.com/socketio/socket.io-client-cpp.git", {submodules = false})
    add_versions("2024.07.17", "da779141a7379cc30c870d48295033bc16a23c66")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end
    add_deps("websocketpp", "rapidjson", "openssl", "asio <=1.32.0")

    on_install("!wasm", function (package)
        io.replace("CMakeLists.txt", "find_package(asio CONFIG REQUIRED)", "find_package(PkgConfig)\npkg_check_modules(asio REQUIRED IMPORTED_TARGET asio)", {plain = true})
        io.replace("CMakeLists.txt", "asio::asio", "PkgConfig::asio", {plain = true})
        io.replace("CMakeLists.txt", " asio ", " PkgConfig::asio ", {plain = true})

        if package:is_plat("windows", "mingw") then
            local syslinks = table.concat(package:dep("openssl"):get("syslinks"), " ")
            io.replace("CMakeLists.txt",
                "target_link_libraries(sioclient PRIVATE ",
                format("target_link_libraries(sioclient PRIVATE %s ", syslinks), {plain = true})
            io.replace("CMakeLists.txt",
                "target_link_libraries(sioclient_tls PRIVATE OpenSSL::SSL OpenSSL::Crypto)",
                format("target_link_libraries(sioclient_tls PRIVATE OpenSSL::SSL OpenSSL::Crypto %s)", syslinks), {plain = true})
        end

        local configs = {"-DUSE_SUBMODULES=OFF", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <string>
            using namespace sio;
            using namespace std;
            void test() {
            socket::ptr current_socket;
            current_socket->on("new message", sio::socket::event_listener_aux(
                [&](string const& name, message::ptr const& data, bool isAck,message::list &ack_resp)
                {
                    string user = data->get_map()["username"]->get_string();
                    string message = data->get_map()["message"]->get_string();
                }));
            }
        ]]}, {configs = {languages = "c++11"}, includes = "sio_client.h"}))
    end)
