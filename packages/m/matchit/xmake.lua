package("matchit")
    set_kind("library", {headeronly = true})
    set_homepage("https://bowenfu.github.io/matchit.cpp/")
    set_description("A lightweight single-header pattern-matching library for C++17 with macro-free APIs.")
    set_license("Apache-2.0")

    add_urls("https://github.com/BowenFu/matchit.cpp/archive/refs/tags/$(version).tar.gz",
           "https://github.com/BowenFu/matchit.cpp.git")
    add_versions("v1.0.1", "52112e323eb3a1e63485334764c345d3e908a244")
    add_versions("2022.11.22", "62c85a91413c61880ededee1a265ecfc87eb8ecd")

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
