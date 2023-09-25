package("utfcpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/nemtrif/utfcpp")
    set_description("UTF8-CPP: UTF-8 with C++ in a Portable Way")
    set_license("BSL-1.0")

    add_urls("https://github.com/nemtrif/utfcpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nemtrif/utfcpp.git")
    add_versions("v3.2.5", "14fd1b3c466814cb4c40771b7f207b61d2c7a0aa6a5e620ca05c00df27f25afd")
    add_versions("v3.2.4", "fde21a4c519eed25f095a1cd8490167409cc70d7b5e9c38756142e588ccb7c7e")
    add_versions("v3.2.3", "3ba9b0dbbff08767bdffe8f03b10e596ca351228862722e4c9d4d126d2865250")
    add_versions("v3.2.1", "8d6aa7d77ad0abb35bb6139cb9a33597ac4c5b33da6a004ae42429b8598c9605")

    add_extsources("apt::libutfcpp-dev", "pacman::utf8cpp")

    add_deps("cmake")

    add_includedirs("include", "include/utf8cpp")

    on_install(function (package)
        local configs = {"-DUTF8_TESTS=OFF", "-DUTF8_INSTALL=ON", "-DUTF8_SAMPLES=OFF"}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local test_snippet = [[
            #define UTF_CPP_CPLUSPLUS 201103L
            #include <utf8cpp/utf8.h>
            void test() {
                std::string line("你好，世界");
                std::u16string u16line = utf8::utf8to16(line);
                std::string u8line = utf8::utf16to8(u16line);
            }
        ]]

        if package:is_plat("windows") then 
            assert(package:check_cxxsnippets({test = test_snippet}, {configs = {languages = "c++11", cxflags = "/utf-8"}}))
        else
            assert(package:check_cxxsnippets({test = test_snippet}, {configs = {languages = "c++11"}}))
        end
    end)
