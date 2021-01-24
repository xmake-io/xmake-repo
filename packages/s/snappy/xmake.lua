package("snappy")

    set_homepage("https://github.com/google/snappy")
    set_description("A fast compressor/decompressor")

    set_urls("https://github.com/google/snappy/archive/$(version).tar.gz",
             "https://github.com/google/snappy.git")

    add_versions("1.1.8", "16b677f07832a612b0836178db7f374e414f94657c138e6993cbfc5dcc58651f")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int args, char** argv) {
                snappy::Compress(nullptr, nullptr);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "snappy.h"}))
    end)
