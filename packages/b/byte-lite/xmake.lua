package("byte-lite")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/martinmoene/byte-lite")
    set_description("byte lite - A C++17-like byte type for C++98, C++11 and later in a single-file header-only library")
    set_license("BSL-1.0")

    add_urls("https://github.com/martinmoene/byte-lite/archive/refs/tags/$(version).tar.gz",
             "https://github.com/martinmoene/byte-lite.git")

    add_versions("v0.3.0", "1a19e237b12bb098297232b0a74ec08c18ac07ac5ac6e659c1d5d8a4ed0e4813")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package, {"-DBYTE_LITE_OPT_BUILD_TESTS=OFF"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <nonstd/byte.hpp>
            void test() {
                auto b1 = nonstd::to_byte( 0x5a );
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
