package("asio2")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/zhllxt/asio2")
    set_description("Header only c++ network library, based on asio, support tcp,udp,http,websocket,rpc,ssl,icmp,serial_port.")
    set_license("BSL-1.0")

    add_urls("https://github.com/zhllxt/asio2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zhllxt/asio2.git")

    add_versions("v2.9", "d173e83a22f6d4ec8697ac533f4cf71051b7aa5c550d24997d991610206dd534")

    add_configs("ssl", {description = "Build OpenSSL module", default = false, type = "boolean"})

    add_patches("2.9", "patches/2.9/remove-const.patch", "6326f333ab2d0484c23bb3cd9cfd5a565030b5525d083677565a693f5f8803b6")

    add_deps("asio 1.29.0", "cereal")
    add_deps("spdlog", { configs = { header_only = false, fmt_external = true } })

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    end

    on_load(function (package)
        if package:config("ssl") then
            package:add("deps", "openssl3")
            package:add("defines", "ASIO2_ENABLE_SSL")
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", "bsd", "cross", function (package)
        os.cp("include/*", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <asio2/asio2.hpp>
            void test() {
                asio2::tcp_server server;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
