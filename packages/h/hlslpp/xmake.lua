package("hlslpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/redorav/hlslpp")
    set_description("Math library using hlsl syntax with SSE/NEON support")
    set_license("MIT")

    add_urls("https://github.com/redorav/hlslpp/archive/refs/tags/$(version).tar.gz")
    add_versions("3.5.1", "5f0a89db4b2a8dcf8237463455d6c03e3f9a090117aed2ba07a7309b239bd88c")
    add_versions("3.5", "9553e69181a5cff770fe68c2dc5afcda638b290c2e83dca635ed695e01aa16df")
    add_versions("3.4", "14541f5350849f04785280add677d7ee4c9a224376e0644beb71318ef18f3531")
    add_versions("3.1", "6f933e43bf8150a41d76a188377e59007897dc87e96be30608e7f2007605d5c4")
    add_versions("3.2.3", "132149d25306cdc56a87c1d6a4a93d3200de4864b5d27d758d235ce4ace64498")

    on_install("linux", "macosx", "bsd", "windows", "android", "iphoneos", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using namespace hlslpp;

                float4 foo4 = float4(1, 2, 3, 4);
                float4x4 fooMatrix4x4 = float4x4( 1, 2, 3, 4,
                                  5, 6, 7, 8,
                                  8, 7, 6, 5,
                                  4, 3, 2, 1);
                float4 myTransformedVector = mul(fooMatrix4x4, foo4);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "hlsl++.h"}))
    end)
