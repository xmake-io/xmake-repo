package("asio2")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/zhllxt/asio2")
    set_description("Header only c++ network library, based on asio, support tcp,udp,http,websocket,rpc,ssl,icmp,serial_port.")
    set_license("BSL-1.0")

    add_urls("https://github.com/zhllxt/asio2.git")
    add_versions("2023.05.09", "ac8c79964d79020091e38fcbb4ae9dccccb3b03c")

    add_deps("asio", "cereal", "fmt", "openssl3")
    add_deps("spdlog", { configs = { header_only = false, fmt_external = true } })

    on_install("windows", "linux", "macosx", "mingw", "bsd", function (package)
        os.cp(path.join("include", "*"), package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <asio2/asio2.hpp>
            void test() {
                asio2::tcp_server server;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
