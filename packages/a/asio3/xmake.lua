package("asio3")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/zhllxt/asio3")
    set_description("Header only c++ network library, based on c++ 20 coroutine and asio")
    set_license("BSL-1.0")

    add_urls("https://github.com/zhllxt/asio3.git")
    add_versions("2023.12.03", "66e76da69b359540fdf15b85bd5f3612b358c1da")

    add_deps("asio", "cereal", "fmt", "openssl3", "nlohmann_json")
    add_deps("spdlog", { configs = { header_only = false, fmt_external = true } })

    on_install("windows", "linux", "macosx", "mingw", "bsd", function (package)
        os.cp(path.join("include"), package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <asio3/tcp/tcp_client.hpp>
            namespace net = ::asio;
            void test() {
                net::io_context ctx;
	            net::tcp_client client(ctx.get_executor());
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
