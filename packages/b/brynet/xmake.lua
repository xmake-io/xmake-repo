package("brynet")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/IronsDu/brynet")
    set_description("A Header-Only cross-platform C++ TCP network library")
    set_license("MIT")

    add_urls("https://github.com/IronsDu/brynet/archive/337c9f375800b46da77116687a61c00ce534b60f.tar.gz",
             "https://github.com/IronsDu/brynet")

    add_versions("2024.06.03", "d35271b8f635959c6507c3bba24ff1ee121c6f27db177564012e54654e813ab8")

    add_configs("openssl", {description = "Enable openssl", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("openssl") then
            package:add("deps", "openssl")
            package:add("defines", "BRYNET_USE_OPENSSL")
        end
    end)

    on_install("!wasm", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto service = brynet::net::IOThreadTcpService::Create();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "brynet/net/TcpService.hpp"}))
    end)
