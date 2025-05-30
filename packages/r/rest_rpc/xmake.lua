package("rest_rpc")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/qicosmos/rest_rpc")
    set_description("c++11, high performance, cross platform, easy to use rpc framework.")
    set_license("MIT")

    add_urls("https://github.com/qicosmos/rest_rpc.git")
    add_versions("2023.6.14", "8782f1d341e1dd18f9fe3a77b8335fd17a5ba585")
    add_versions("2024.7.26", "35761edb55dff9ccdc87000062e84172bbd5b29b")

    add_deps("asio 1.32.0")
    add_deps("msgpack-cxx", {configs = {boost = false}})

    if is_plat("mingw") then
        add_syslinks("ws2_32")
    end

    on_install("windows", "macosx", "linux", "mingw", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "rest_rpc.hpp"
            void test() {
                rest_rpc::rpc_client client("127.0.0.1", 9000);
                client.connect();
                int result = client.call<int>("add", 1, 2);
                client.run();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
