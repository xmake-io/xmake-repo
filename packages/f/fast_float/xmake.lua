package("fast_float")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/fastfloat/fast_float")
    set_description("Fast and exact implementation of the C++ from_chars functions for float and double types: 4x faster than strtod")
    set_license("Apache-2.0")

    add_urls("https://github.com/fastfloat/fast_float/archive/refs/tags/$(version).tar.gz",
             "https://github.com/fastfloat/fast_float.git")
    add_versions("v3.5.0", "4f74bd84b2c5f37b136375ee5498476f6ba29bf158727adb5cd844a70af2ba74")
    add_versions("v3.4.0", "a242877d2fae81ca412033f5ebf5dbc43cb029c56b4af78e33106b9a69f8f58e")

    if is_plat("wasm") then
        add_patches("v3.4.0", path.join(os.scriptdir(), "patches", "emscripten_fix.patch"), "482705431f67e6f0a375ed7bfe87d6856e7d13f071db6157e1d5659834b0eb50")
    end

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
        ]]}, {configs = {languages = "c++11"}, includes = {"fast_float/fast_float.h"}}))
    end)
