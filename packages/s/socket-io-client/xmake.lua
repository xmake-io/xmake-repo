package("socket-io-client")
    set_homepage("https://github.com/socketio/socket.io-client-cpp")
    set_description("C++11 implementation of Socket.IO client")
    set_license("MIT")

    add_urls("https://github.com/socketio/socket.io-client-cpp.git", {alias = "github", submodules = false, version = function (version)
        local hash = "da779141a7379cc30c870d48295033bc16a23c66"
        if version:le("2024.07.17") then
            hash = "da779141a7379cc30c870d48295033bc16a23c66"
        end
        return hash
    end})

    add_versions("2024.07.17", "da779141a7379cc30c870d48295033bc16a23c66")
    -- Synchronize with 03.06.2024
    -- add_patches("3.1.0", [[https://github.com/socketio/socket.io-client-cpp/compare/3.1.0%2E%2E%2.patch]], "31f3e6be5f618c8e3d670351d47169edacedd24c8c59396769d0d693ab08b673")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake", "websocketpp", "rapidjson", "openssl")
    add_deps("boost", {configs = {context = true, asio = true}}) 
    -- add_deps("asio")

    if is_host("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end

    on_install(function (package)
        io.replace("CMakeLists.txt", "-DASIO_STANDALONE", "", {plain = true})
        io.replace("CMakeLists.txt", "BUILD_TESTING", "0", {plain = true})

        -- io.replace("CMakeLists.txt", "find_package(asio CONFIG REQUIRED)",
-- [[find_package(PkgConfig)
-- pkg_check_modules(asio REQUIRED IMPORTED_TARGET asio)]], {plain = true})
        -- io.replace("CMakeLists.txt", "asio::asio", "PkgConfig::asio", {plain = true})

        io.replace("CMakeLists.txt", "find_package(asio CONFIG REQUIRED)", "find_package(Boost REQUIRED COMPONENTS asio)", {plain = true})
        io.replace("CMakeLists.txt", "asio::asio", "Boost::asio", {plain = true})


        io.replace("CMakeLists.txt", "find_package(RapidJSON CONFIG REQUIRED)", 
[[find_package(PkgConfig)
pkg_check_modules(rapidjson REQUIRED IMPORTED_TARGET RapidJSON)]], {plain = true})
        io.replace("CMakeLists.txt", "rapidjson)", "PkgConfig::rapidjson)", {plain = true})

        -- io.replace("CMakeLists.txt", "${OPENSSL_INCLUDE_DIR}", "${OPENSSL_INCLUDE_DIR} PkgConfig::rapidjson")

        for _, file in ipairs(table.join(os.files("src/**.cpp"), os.files("src/**.h"))) do
            io.replace(file, [[#include <asio/]], [[#include <boost/asio/]], {plain = true})
            io.replace(file, [[boost/asio/error_code.hpp]], [[boost/asio/error.hpp]], {plain = true})
        end

        local configs = {"-DUSE_SUBMODULES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs) --, {packagedeps = {"websocketpp", "boost", "rapidjson"}}
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace sio;
            void test() {
            socket::ptr current_socket;
            current_socket->on("new message", sio::socket::event_listener_aux([&](string const& name, message::ptr const& data, bool isAck,message::list &ack_resp)
                {
                    _lock.lock();
                    string user = data->get_map()["username"]->get_string();
                    string message = data->get_map()["message"]->get_string();
                    EM(user<<":"<<message);
                    _lock.unlock();
                }));
            }
        ]]}, {configs = {languages = "c++11"}, includes = "sio_client.h"}))
    end)
