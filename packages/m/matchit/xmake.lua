package("matchit")
    set_kind("library", {headeronly = true})
    set_homepage("https://bowenfu.github.io/matchit.cpp/")
    set_description("A lightweight single-header pattern-matching library for C++17 with macro-free APIs.")
    set_license("Apache-2.0")

    add_urls("https://github.com/BowenFu/matchit.cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/BowenFu/matchit.cpp.git")

    add_versions("v1.0.1", "2860cb85febf37220f75cef5b499148bafc9f5541fe1298e11b0c169bb3f31ac")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package, {"-DBUILD_TESTING=OFF"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
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
        ]]}, {configs = {languages = "c++17"}, includes = "matchit.h"}))
    end)
