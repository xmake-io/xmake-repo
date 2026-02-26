package("fast_float")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/fastfloat/fast_float")
    set_description("Fast and exact implementation of the C++ from_chars functions for float and double types: 4x faster than strtod")
    set_license("Apache-2.0")

    add_urls("https://github.com/fastfloat/fast_float/archive/refs/tags/$(version).tar.gz",
             "https://github.com/fastfloat/fast_float.git")

    add_versions("v8.2.3", "fa811076bad7b7151ce826005a7213971c879b192ee4505a7016c8413038c2d0")
    add_versions("v3.4.0", "a242877d2fae81ca412033f5ebf5dbc43cb029c56b4af78e33106b9a69f8f58e")
    add_versions("v3.5.1", "8558bf9c66ccd2f7d03c94461a107f49ad9cf6e4f6c0c84e148fec0aa32b4dd9")
    add_versions("v3.10.1", "d162c21c1dc538dbc6b3bb6d1317a7808f2eccef78638445630533f5bed902ee")
    add_versions("v5.2.0", "72bbfd1914e414c920e39abdc81378adf910a622b62c45b4c61d344039425d18")
    add_versions("v5.3.0", "2f3bc50670455534dcaedc9dcd0517b71152f319d0cec8625f21c51d23eaf4b9")
    add_versions("v6.0.0", "7e98671ef4cc7ed7f44b3b13f80156c8d2d9244fac55deace28bd05b0a2c7c8e")
    add_versions("v6.1.0", "a9c8ca8ca7d68c2dbb134434044f9c66cfd4c383d5e85c36b704d30f6be82506")
    add_versions("v6.1.1", "10159a4a58ba95fe9389c3c97fe7de9a543622aa0dcc12dd9356d755e9a94cb4")
    add_versions("v6.1.3", "7dd99cc2ff44e07dc2a42bed0c6b8c4a8ee4e3b1c330f77073b6cfdb48724c8e")
    add_versions("v6.1.4", "12cb6d250824160ca16bcb9d51f0ca7693d0d10cb444f34f1093bc02acfce704")
    add_versions("v6.1.5", "597126ff5edc3ee59d502c210ded229401a30dafecb96a513135e9719fcad55f")
    add_versions("v6.1.6", "4458aae4b0eb55717968edda42987cabf5f7fc737aee8fede87a70035dba9ab0")
    add_versions("v7.0.0", "d2a08e722f461fe699ba61392cd29e6b23be013d0f56e50c7786d0954bffcb17")
    add_versions("v8.0.0", "f312f2dc34c61e665f4b132c0307d6f70ad9420185fa831911bc24408acf625d")
    add_versions("v8.0.2", "e14a33089712b681d74d94e2a11362643bd7d769ae8f7e7caefe955f57f7eacd")
    add_versions("v8.1.0", "4bfabb5979716995090ce68dce83f88f99629bc17ae280eae79311c5340143e1")
    add_versions("v8.2.1", "e18b59feaff3aca8e9426e6969f18a86b291e6ec6553744aa6b5a033a21d62ba")
    add_versions("v8.2.2", "e64b5fff88e04959154adbd5fb83331d91f2e04ac06454671cdfcbdff172b158")

    if is_plat("wasm") then
        add_patches("v3.4.0", path.join(os.scriptdir(), "patches", "emscripten_fix.patch"), "482705431f67e6f0a375ed7bfe87d6856e7d13f071db6157e1d5659834b0eb50")
    end

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                const std::string input = "3.1416 xyz ";
                double result;
                auto answer = fast_float::from_chars(input.data(), input.data() + input.size(), result);
            }
        ]]}, {configs = {languages = "c++14"}, includes = {"fast_float/fast_float.h"}}))
    end)
