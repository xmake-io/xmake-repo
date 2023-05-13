package("asio")

    set_kind("library", {headeronly = true})
    set_homepage("http://think-async.com/Asio/")
    set_description("Asio is a cross-platform C++ library for network and low-level I/O programming that provides developers with a consistent asynchronous model using a modern C++ approach.")
    set_license("BSL-1.0")

    add_urls("https://sourceforge.net/projects/asio/files/asio/$(version) (Stable)/asio-$(version).tar.gz", {alias = "sourceforge"})
    add_urls("https://github.com/chriskohlhoff/asio/archive/refs/tags/asio-$(version).tar.gz", {alias = "github", version = function (version) return version:gsub("%.", "-") end})
    add_versions("github:1.28.0", "226438b0798099ad2a202563a83571ce06dd13b570d8fded4840dbc1f97fa328")
    add_versions("github:1.24.0", "cbcaaba0f66722787b1a7c33afe1befb3a012b5af3ad7da7ff0f6b8c9b7a8a5b")
    add_versions("github:1.21.0", "5d2d2dcb7bfb39bff941cabbfc8c27ee322a495470bf0f3a7c5238648cf5e6a9")
    add_versions("sourceforge:1.20.0", "4cd5cd0ad97e752a4075f02778732a3737b587f5eeefab59cd98dc43b0dcadb3")
    add_versions("github:1.20.0", "34a8f07be6f54e3753874d46ecfa9b7ab7051c4e3f67103c52a33dfddaea48e6")

    on_install(function (package)
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
