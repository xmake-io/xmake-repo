package("alpaca")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/p-ranav/alpaca")
    set_description("Serialization library written in C++17 - Pack C++ structs into a compact byte-array without any macros or boilerplate code")
    set_license("MIT")

    add_urls("https://github.com/p-ranav/alpaca/archive/refs/tags/$(version).tar.gz",
             "https://github.com/p-ranav/alpaca.git", {submodules = false})
    -- 2024.07.20
    add_versions("v0.2.1", "ea5ab2aaa97be20d48c0ce99eb90321f1db91929")

    add_deps("cmake")

    on_install("!wasm and !bsd", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            struct Config {
                std::string device;
            };
            void test() {
                Config c{"/dev/video0"};
                std::vector<uint8_t> bytes;
                auto bytes_written = alpaca::serialize(c, bytes);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "alpaca/alpaca.h"}))
    end)
