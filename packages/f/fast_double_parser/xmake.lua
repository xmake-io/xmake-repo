package("fast_double_parser")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/lemire/fast_double_parser")
    set_description("Fast function to parse strings containing decimal numbers into double-precision (binary64) floating-point values.")
    set_license("Apache-2.0")

    add_urls("https://github.com/lemire/fast_double_parser/archive/refs/tags/$(version).tar.gz",
             "https://github.com/lemire/fast_double_parser.git")
    add_versions("v0.5.0", "afbd2d42facd037bf3859856a8fe4112e4d7ded942255f6c0e6c17689d41f645")
    add_versions("v0.7.0", "eb80a1d9c406bbe8cb22fffd3c007651f716abd03225009302d8aba8e9c4df77")

    on_install("windows|x64", "macosx", "linux", "mingw", "android", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                double x;
                char str[] = "0.11";
                const char *endptr = fast_double_parser::parse_number(str, &x);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "fast_double_parser.h"}))
    end)
