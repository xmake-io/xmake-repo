package("socket-io-client")
    set_homepage("https://github.com/socketio/socket.io-client-cpp")
    set_description("C++11 implementation of Socket.IO client")
    set_license("MIT")

    add_urls("https://github.com/socketio/socket.io-client-cpp/archive/refs/tags/$(version).tar.gz")
    add_urls("https://github.com/socketio/socket.io-client-cpp.git", {alias = "git", submodules = false})

    add_versions("git:2025.08.28", "3b7be7e4173b5bdeed393966e3274f65d513a280")
    add_versions("git:2024.07.17", "da779141a7379cc30c870d48295033bc16a23c66")

    add_versions("3.1.0", "f54dd36b8e5618d028c7c42f0c1a83a0d3a58f9239cf4b770f6b02b925909597")
    add_versions("3.0.0", "6c11383eaea837d3dc4183d31f8d27f5ce08b3987f4903708983044115ebd95a")
    add_versions("2.1.0", "f5bd6260403dd6c62c6dbf97ca848f5db69908edbdc0a365e28be06cdd2a44f8")

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
        -- gcc14
        io.replace("src/sio_message.h", "#include <string>", "#include <string>\n#include <cstdint>", {plain = true})

        if package:version() and package:version():le("3.1.0") then
            os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
            import("package.tools.xmake").install(package, {version = package:version_str()})
            return
        end

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
