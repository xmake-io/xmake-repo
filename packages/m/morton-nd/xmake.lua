package("morton-nd")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/morton-nd/morton-nd")
    set_description("A header-only compile-time Morton encoding / decoding library for N dimensions.")
    set_license("MIT")

    add_urls("https://github.com/morton-nd/morton-nd/archive/refs/tags/$(version).tar.gz",
             "https://github.com/morton-nd/morton-nd.git")

    add_versions("v4.0.0", "29337c7f7afb6361dd483ca4fe2111aad9d590f3b9d3fe519856a5bdf450e059")

    add_deps("cmake")

    on_install(function (package)
        io.replace("include/morton-nd/mortonND_BMI2.h", "#include <immintrin.h>", "#include <immintrin.h>\n#include <cstdint>", {plain = true})
        io.replace("include/morton-nd/mortonND_LUT.h", "#include <limits>", "#include <limits>\n#include <cstdint>", {plain = true})
        import("package.tools.cmake").install(package, {"-DBUILD_TESTING=OFF"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                constexpr auto MortonND_4D_Enc = mortonnd::MortonNDLutEncoder<4, 16, 8>();
            }
        ]]}, {configs = {languages = "c++14"}, includes = "morton-nd/mortonND_LUT.h"}))
    end)
