package("fast_float")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/fastfloat/fast_float")
    set_description("Fast and exact implementation of the C++ from_chars functions for float and double types: 4x faster than strtod")
    set_license("Apache-2.0")

    add_urls("https://github.com/fastfloat/fast_float/archive/refs/tags/$(version).tar.gz",
             "https://github.com/fastfloat/fast_float.git")
    add_versions("v3.4.0", "a242877d2fae81ca412033f5ebf5dbc43cb029c56b4af78e33106b9a69f8f58e")

    on_install(function (package)
        os.vcp("include/fast_float", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                const std::string input =  "3.1416 xyz ";
                double result;
                auto answer = fast_float::from_chars(input.data(), input.data()+input.size(), result);
            }
        ]]}, {includes = {"chipmunk/chipmunk.h"}}))
    end)
