package("asio2")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/zhllxt/asio2")
    set_description("Header only c++ network library, based on asio, support tcp,udp,http,websocket,rpc,ssl,icmp,serial_port.")
    set_license("BSL-1.0")

    add_urls("https://github.com/zhllxt/asio2/archive/refs/tags/$(version).zip",
             "https://github.com/zhllxt/asio2.git")

    add_versions("v2.9", "3ce0b41300954ffc13948bd51af6430e324b1c28e26d2eb5a83e775cf38c12b4")

    add_patches("2.9", "patches/2.9/remove-const.patch", "6326f333ab2d0484c23bb3cd9cfd5a565030b5525d083677565a693f5f8803b6")

    add_deps("asio", "cereal", "fmt", "openssl3")
    add_deps("spdlog", { configs = { header_only = false, fmt_external = true } })

    on_install("windows", "linux", "macosx", "mingw", "bsd", "cross", function (package)
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
