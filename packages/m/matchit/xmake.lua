package("matchit")
    set_kind("library", {headeronly = true})
    set_homepage("https://bowenfu.github.io/matchit.cpp/")
    set_description("A lightweight single-header pattern-matching library for C++17 with macro-free APIs.")
    set_license("Apache-2.0")

    add_urls("https://github.com/BowenFu/matchit.cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/BowenFu/matchit.cpp.git", {alias = "release"})
    add_urls("https://github.com/BowenFu/matchit.cpp.git", {alias = "trunk"})
    add_versions("release:v1.0.1", "2860cb85febf37220f75cef5b499148bafc9f5541fe1298e11b0c169bb3f31ac")
    add_versions("trunk:2022.11.22", "62c85a91413c61880ededee1a265ecfc87eb8ecd")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "matchit.h"
            constexpr int32_t gcd(int32_t a, int32_t b) {
                using namespace matchit;
                return match(a, b)(
                    pattern | ds(_, 0) = [&] { return a >= 0 ? a : -a; },
                    pattern | _        = [&] { return gcd(b, a%b); }
                );
            }
            void test() {
                static_assert(gcd(12, 6) == 6);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
