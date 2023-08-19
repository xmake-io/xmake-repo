package("variant-lite")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/martinmoene/variant-lite")
    set_description("variant lite - A C++17-like variant, a type-safe union for C++98, C++11 and later in a single-file header-only library")
    set_license("BSL-1.0")

    add_urls("https://github.com/martinmoene/variant-lite.git")
    add_versions("2022.12.03", "5015e841cf143487f2d7e2f619b618d455658fab")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <nonstd/variant.hpp>
            void test() {
                nonstd::variant<char, int, long> var;
            }
        ]]}))
    end)
