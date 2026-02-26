package("omath")
    set_homepage("http://libomath.org")
    set_description("Cross-platform modern general purpose math library written in C++23")
    set_license("zlib")

    add_urls("https://github.com/orange-cpp/omath/archive/refs/tags/$(version).tar.gz",
             "https://github.com/orange-cpp/omath.git", {submodules = false})

    add_versions("v5.0.0", "1ec20f2216f46ca67fc24b9b3fef39e9397470e486ca40c5a3c3dd1574cfcdc3")
    add_versions("v4.7.0", "39ae487634d8df85bc3e21a72f6f58c76a0f654883ea2ee23f14a1db1c4ed802")
    add_versions("v4.6.1", "2d110f10340eede0b4ed7891af2da76bcfbaeb4fe48a8a2d69f617759361f4e0")
    add_versions("v4.5.0", "2861c0dbb06d07ba83ebb1458fbf2c8b1cde0e7e9b137809007cd45a86ccc3c6")
    add_versions("v4.4.0", "46fe67d0524c643b28892d2c27b33c5bb4941b0cd5393390cc17e11ae5d31741")
    add_versions("v4.3.0", "e21c2e1ff22360715ef6dd231e9f0ac506256b786a246061fac2dfd4cd37d20d")
    add_versions("v4.2.0", "f1482c5fd0de0ed26b8197c51e4eb59425c541d4819a3ed6f9639aef251b4a53")
    add_versions("v4.1.0", "df5b6774a747ef91b8a34b23db774e92ecba3d3907cc060e36985ec2bd31c6d5")
    add_versions("v4.0.1", "983c17abb126dd4a0289c88be94f29af4772624500d75c0702e391e64fe65966")
    add_versions("v3.10.1", "17244abf5ffe9164a6f0c71cc8575e21ddb22d9816e949db924489fec0c1d72c")
    add_versions("v3.9.4", "7e4409ac40dc44f3c587067063bc66ecfa81ee9b1eeeb23a33f3952371b4eccf")
    add_versions("v3.9.3", "b2f3bf035aaa40cd527b5676af2ca8c581f78eca7a41ff0db6b93a237bab4aaf")
    add_versions("v3.9.0", "a87b77e00d3cbaad171a1682976359106fecdc20d99367f2b61719bc46b19776")
    add_versions("v3.8.2", "e759aba554f9d50147931852c13408ff0bd302a787ff28818d19d4dc1a8f7fd0")
    add_versions("v3.8.1", "aaea99570c382478f825af759a2b0a214b429c74a9a5492ddd2866c836e85f4e")

    add_patches("v4.5.0", "patches/v4.5.0/fix-freebsd.patch", "0d82edf375b605dacdffd5130898df34894fc5d4ef2610495de40e3a3f8faf90")
    add_patches("v3.9.3", "patches/v3.9.3/fix-cend.patch", "1e45f4e702963bddd456b85c39dbda9a64df5903f2d5e7568ac9fbf920ec8681")
    add_patches("v3.9.0", "patches/v3.9.0/fix-fastcall.patch", "c439cbde15949786e87241a4a81575296e81cfdca8ec76192b5ff228126fa02c")
    add_patches("v3.8.1", "patches/v3.8.1/fix-build.patch", "c1554cf0cdd027d6386544871d6248c868f8f95add343660334888da52119ae9")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end
    if is_arch("x86_64", "x64", "x86", "i386", "i686") then
        add_configs("avx2",  {description = "Enable AVX2", default = true, type = "boolean"})
    end
    add_configs("imgui", {description = "Define method to convert omath types to imgui types", default = true, type = "boolean"})

    add_deps("cmake")

    on_check(function (package)
        assert(package:check_cxxsnippets({test = [[
        template <typename T, T Min, T Max>
        struct Angle {
            static T get_min() { return Min; }
        };
        int main() {
            Angle<float, 0.0f, 180.0f> a;
            return 0;
        }
        ]]}, {configs = {languages = "c++23"}}), "package(omath): Your compiler does not support floating-point non-type template.")
    end)

    on_load(function (package)
        if package:config("imgui") then
            package:add("deps", "imgui")
        end
    end)

    on_install(function (package)
        local configs = {
            "-DOMATH_BUILD_TESTS=OFF",
            "-DOMATH_BUILD_BENCHMARK=OFF",
            "-DOMATH_THREAT_WARNING_AS_ERROR=OFF",
            "-DOMATH_BUILD_EXAMPLES=OFF",
        }
        table.insert(configs, "-DOMATH_USE_AVX2=" .. (package:config("avx2") and "ON" or "OFF"))
        table.insert(configs, "-DOMATH_IMGUI_INTEGRATION=" .. (package:config("imgui") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DOMATH_BUILD_AS_SHARED_LIBRARY=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #if __has_include(<omath/omath.hpp>)
                #include <omath/omath.hpp>
            #else
                #include <omath/vector2.hpp>
            #endif
            void test() {
                omath::Vector2 w = omath::Vector2(20.0, 30.0);
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
