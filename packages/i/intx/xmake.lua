package("intx")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/chfast/intx")
    set_description("Extended precision integer C++ library")
    set_license("Apache-2.0")

    add_urls("https://github.com/chfast/intx/archive/refs/tags/$(version).tar.gz",
             "https://github.com/chfast/intx.git")

    add_versions("v0.12.0", "d68ff5dde9a2f340c73be67888f3f72bb18a2ad30aa16cd663ec3bc611afc9b4")
    add_versions("v0.11.0", "bff2a78e3a9a3b9bbabf50500feae65bc0ec50a2364f4a83768277d6eba7a844")

    add_deps("cmake")

    on_check(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <concepts>
            #include <algorithm>
            #include <string>
            void test(std::signed_integral auto x) {
                std::string s;
                std::ranges::reverse(s);
            }
        ]]}, {configs = {languages = "c++20"}}), "package(intx) Require at least C++20.")
    end)

    on_install(function (package)
        import("package.tools.cmake").install(package, {"-DINTX_TESTING=OFF"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto x = static_cast<int>(intx::uint512{1} / (intx::uint512{1} << 111));
            }
        ]]}, {configs = {languages = "c++20"}, includes = {"intx/intx.hpp"}}))
    end)
