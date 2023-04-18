package("brynet")

    set_homepage("https://github.com/IronsDu/brynet")
    set_description("Header Only Cross platform high performance TCP network library using C++ 11")

    set_urls("https://github.com/IronsDu/brynet/archive/v$(version).zip")
    add_urls("https://github.com/IronsDu/brynet.git")
    add_versions("1.0.9", "a264a6aaf3ec9fd5aa4029a8857be813be203ee7b93997b0c1c5c5e2c5f89a2a")
    add_versions("1.12.2", "7c789c1a9a9c3f2cac73e98a96d18338d876b0bcd100c8e71d755a6bf53125ab")

    if is_plat("windows") then
        add_syslinks("Ws2_32")
    end

    on_install("windows", "linux", "android", "cross", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int argc, char** argv) {
                auto service = brynet::net::TcpService::Create();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "brynet/net/TcpService.hpp"}))
    end)
