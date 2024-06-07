package("simdutf")
    set_homepage("https://simdutf.github.io/simdutf/")
    set_description("Unicode routines (UTF8, UTF16, UTF32): billions of characters per second using SSE2, AVX2, NEON, AVX-512. Part of Node.js.")
    set_license("Apache-2.0")

    add_urls("https://github.com/simdutf/simdutf/archive/refs/tags/$(version).tar.gz",
             "https://github.com/simdutf/simdutf.git")

    add_versions("v5.2.8", "2706f1bef85a6d8598f82defd3848f1c5100e2e065c5d416d993118b53ea8d77")
    add_versions("v5.2.6", "ab9e56facf7cf05f4e9d062a0adef310fc6a0f82a8132e8ec1e1bb7ab5e234df")
    add_versions("v5.2.4", "36281d6489a4a8c2b5bfac2d41c03dce8fc89ec1cda15cc05c53d44f5ad30b4d")
    add_versions("v5.2.3", "dfa55d85c3ee51e9b52e55c02701b16f83dcf1921e1075b67f99b1036df5adb8")
    add_versions("v4.0.9", "599e6558fc8d06f8346e5f210564f8b18751c93d83bce1a40a0e6a326c57b61e")
    add_versions("v3.2.17", "c24e3eec1e08522a09b33e603352e574f26d367a7701bf069a65881f64acd519")

    add_configs("iconv", {description = "Whether to use iconv as part of the CMake build if available.", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("iconv") then
            package:add("deps", "libiconv")
        end
    end)

    on_install(function (package)
        local configs = {"-DSIMDUTF_TESTS=OFF", "-DSIMDUTF_BENCHMARKS=OFF", "-DSIMDUTF_TOOLS=OFF", }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSIMDUTF_ICONV=" .. (package:config("iconv") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", "add_subdirectory(singleheader)", "", {plain = true})
        io.replace("src/CMakeLists.txt", "/WX", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <simdutf.h>
            void test() {
                bool validutf8 = simdutf::validate_utf8("1234", 4);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
