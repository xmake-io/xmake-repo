package("omath")
    set_homepage("http://libomath.org")
    set_description("Cross-platform modern general purpose math library written in C++23")
    set_license("zlib")

    add_urls("https://github.com/orange-cpp/omath/archive/refs/tags/$(version).tar.gz",
             "https://github.com/orange-cpp/omath.git", {submodules = false})

    add_versions("v3.8.1", "aaea99570c382478f825af759a2b0a214b429c74a9a5492ddd2866c836e85f4e")

    add_patches("v3.8.1", "patches/v3.8.1/fix-build.patch", "c1554cf0cdd027d6386544871d6248c868f8f95add343660334888da52119ae9")

    if is_arch("x86_64", "x64", "x86", "i386", "i686") then
        add_configs("avx2",  {description = "Enable AVX2", default = true, type = "boolean"})
    end
    add_configs("imgui", {description = "Define method to convert omath types to imgui types", default = true, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("imgui") then
            package:add("deps", "imgui")
        end
    end)

    on_install("!macosx and !iphoneos and !android and !bsd", function (package)
        local configs = {
            "-DOMATH_BUILD_TESTS=OFF",
            "-DOMATH_BUILD_BENCHMARK=OFF",
            "-DOMATH_THREAT_WARNING_AS_ERROR=OFF",
            "-DOMATH_BUILD_EXAMPLES=OFF",
        }
        table.insert(configs, "-DOMATH_USE_AVX2=" .. (package:config("avx2") and "ON" or "OFF"))
        table.insert(configs, "-DOMATH_IMGUI_INTEGRATION=" .. (package:config("imgui") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DOMATH_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
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
