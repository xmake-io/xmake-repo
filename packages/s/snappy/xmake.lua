package("snappy")

    set_homepage("https://github.com/google/snappy")
    set_description("A fast compressor/decompressor")

    set_urls("https://github.com/google/snappy/archive/$(version).tar.gz",
             "https://github.com/google/snappy.git")

    add_versions("1.1.8", "16b677f07832a612b0836178db7f374e414f94657c138e6993cbfc5dcc58651f")

    add_deps("cmake")

    add_configs("avx", {description = "Use the AVX instruction set", default = false, type = "boolean"})
    add_configs("avx2", {description = "Use the AVX2 instruction set", default = false, type = "boolean"})

    on_install(function (package)
        local configs = {"-DSNAPPY_BUILD_TESTS=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSNAPPY_REQUIRE_AVX=" .. (package:config("avx") and "ON" or "OFF"))
        table.insert(configs, "-DSNAPPY_REQUIRE_AVX2=" .. (package:config("avx2") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int args, char** argv) {
                snappy::Compress(nullptr, nullptr);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "snappy.h"}))
    end)
