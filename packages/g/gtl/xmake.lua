package ("gtl")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/greg7mdp/gtl")
    set_description("Greg's Template Library of useful classes.")
    set_license("Apache-2.0")
    set_urls("https://github.com/greg7mdp/gtl.git")

    add_versions("1.01", "94cb5022283a2c6f54188ccf565d36784b1cf84bd4e7c74e954db2dc18753403")
    add_versions("v1.1.0", "d18b6124c51e99d8e7e2cc1f1b3e8a8c649c2872b7a1e9987417c9166c9f427f")
    add_versions("v1.1.1", "3c87cad50bc2de6d17596c796c81521ff80b00d66674faa52f147544c4951270")
    add_versions("v1.1.2", "22ac9fb43608c7ddccb983096f5dadb036e5d3122d9194cdb42fee67d754c552")
    add_versions("v1.1.3", "c667690eeecf37f660d8a61bca1076e845154bc535c44ec0d2404c04c66ae228")
    add_versions("v1.1.4", "b51b9951d11fb73ed22360a96a3f6c691c15202c3b14c79dcdd498da80b6502d")
    add_versions("v1.1.5", "2d943d2ccc33c6c662918efc51782dac414354a1458441f16041a98eec164bda")
    add_versions("v1.1.6", "d90224c0b26deeab730b02857a20c6c7dee014ecd7a76aaa7a469c35049fe3a9")
    add_versions("v1.1.8", "6bda4c07bd966a88740ee07e3df23863a93d7b5365e0eea7f13cde9eda961b86")
    add_versions("v1.2.0", "1547ab78f62725c380f50972f7a49ffd3671ded17a3cb34305da5c953c6ba8e7")

    add_deps("cmake")
    on_install("windows", "linux", "macosx", "mingw", "msys", function (package)
        local configs = {
        "-DGTL_BUILD_TESTS=OFF",
        "-DGTL_BUILD_EXAMPLES=OFF",
        "-DGTL_BUILD_BENCHMARKS=OFF",
    }
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("gtl/phmap.hpp"))
    end)
