package("asio")

    set_kind("library", {headeronly = true})
    set_homepage("http://think-async.com/Asio/")
    set_description("Asio is a cross-platform C++ library for network and low-level I/O programming that provides developers with a consistent asynchronous model using a modern C++ approach.")
    set_license("BSL-1.0")

    add_urls("https://sourceforge.net/projects/asio/files/asio/$(version) (Stable)/asio-$(version).tar.gz", {alias = "sourceforge"})
    add_urls("https://github.com/chriskohlhoff/asio/archive/refs/tags/asio-$(version).tar.gz", {alias = "github", version = function (version) return version:gsub("%.", "-") end})

    add_versions("github:1.36.0", "0310a76b27e1854f09f696b30de57dc490b5e1b17faed1eb8c9a2891f956e52b")
    add_versions("github:1.35.0", "df4c5b285ed450d969f8e3eb0e0dfb30b4aa47b516cc4dd1f5d664dcf6ff8ca9")
    add_versions("github:1.34.2", "f3bac015305fbb700545bd2959fbc52d75a1ec2e05f9c7f695801273ceb78cf5")
    add_versions("github:1.34.0", "061ed6c8b97527756aed3e34d2cbcbcb6d3c80afd26ed6304f51119e1ef6a1cd")
    add_versions("github:1.32.0", "f1b94b80eeb00bb63a3c8cef5047d4e409df4d8a3fe502305976965827d95672")
    add_versions("github:1.30.2", "755bd7f85a4b269c67ae0ea254907c078d408cce8e1a352ad2ed664d233780e8")
    add_versions("github:1.29.0", "44305859b4e6664dbbf853c1ef8ca0259d694f033753ae309fcb2534ca20f721")
    add_versions("github:1.28.0", "226438b0798099ad2a202563a83571ce06dd13b570d8fded4840dbc1f97fa328")
    add_versions("github:1.24.0", "cbcaaba0f66722787b1a7c33afe1befb3a012b5af3ad7da7ff0f6b8c9b7a8a5b")
    add_versions("github:1.21.0", "5d2d2dcb7bfb39bff941cabbfc8c27ee322a495470bf0f3a7c5238648cf5e6a9")
    add_versions("sourceforge:1.20.0", "4cd5cd0ad97e752a4075f02778732a3737b587f5eeefab59cd98dc43b0dcadb3")
    add_versions("github:1.20.0", "34a8f07be6f54e3753874d46ecfa9b7ab7051c4e3f67103c52a33dfddaea48e6")

    if is_plat("mingw") then
        add_syslinks("ws2_32", "bcrypt")
    end

    on_install("!wasm", function (package)
        if os.isdir("asio") then
            os.cp("asio/include/asio.hpp", package:installdir("include"))
            os.cp("asio/include/asio", package:installdir("include"))
        else
            os.cp("include/asio.hpp", package:installdir("include"))
            os.cp("include/asio", package:installdir("include"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                asio::io_context io_context;
                asio::steady_timer timer(io_context);
                timer.expires_at(asio::steady_timer::clock_type::time_point::min());
            }
        ]]}, {configs = {languages = "c++14"}, includes = "asio.hpp"}))
    end)
