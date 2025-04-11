package("socket-io-client")
    set_homepage("https://github.com/socketio/socket.io-client-cpp")
    set_description("C++11 implementation of Socket.IO client")
    set_license("MIT")

    add_urls("https://github.com/socketio/socket.io-client-cpp.git")
    add_versions("2024.07.17", "da779141a7379cc30c870d48295033bc16a23c66")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake", "websocketpp", "rapidjson", "openssl")
    add_deps("asio <=1.32.0")

    if is_host("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end

    on_install("!wasm", function (package)
        io.replace("CMakeLists.txt", "if((CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME AND BUILD_TESTING) OR BUILD_UNIT_TESTS)", "if(0)", {plain = true})

        io.replace("CMakeLists.txt", "find_package(asio CONFIG REQUIRED)",
[[find_package(PkgConfig)
pkg_check_modules(asio REQUIRED IMPORTED_TARGET asio)]], {plain = true})
        io.replace("CMakeLists.txt", "asio::asio", "PkgConfig::asio", {plain = true})

        io.replace("CMakeLists.txt", "find_package(RapidJSON CONFIG REQUIRED)", 
[[pkg_check_modules(rapidjson REQUIRED IMPORTED_TARGET RapidJSON)]], {plain = true})
        io.replace("CMakeLists.txt", "rapidjson)", "PkgConfig::rapidjson)", {plain = true})

        local configs = {"-DUSE_SUBMODULES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = {"asio"}})
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
