package("cachelib")
    set_homepage("www.cachelib.org")
    set_description("An implementation of the QUIC transport protocol.")
    set_license("Apache-2.0")

    add_urls("https://github.com/facebook/CacheLib/archive/refs/tags/v$(version).00.tar.gz",
             "https://github.com/facebook/CacheLib.git")

    add_versions("2024.06.10", "65afd2e313b6852faa84d7d9140493133854e69da40b8973ea9e29a26aca7fc9")

    add_deps("cmake", "folly", "fizz", "wangle", "fbthrift", "numactl", "sparse-map", "fmt")

    on_install("linux", function (package)
        local configs = {"-DBUILD_TESTS=OFF",
                         "-DCMAKE_CXX_STANDARD=17"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "cachelib/allocator/CacheAllocator.h"
            void test() {
                cachelib::LruAllocator::Config config;
                config.setCacheSize(1 * 1024 * 1024 * 1024)
                    .setCacheName("My Use Case")
                    .setAccessConfig({25, 10})
                    .validate();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
