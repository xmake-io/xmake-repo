package("utfcpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/nemtrif/utfcpp")
    set_description("UTF8-CPP: UTF-8 with C++ in a Portable Way")
    set_license("BSL-1.0")

    add_urls("https://github.com/nemtrif/utfcpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nemtrif/utfcpp.git")
    add_versions("v4.0.9", "0902218f606e942ccc10724df8a988fc993c12da4b3adeace28a7f0211970e08")
    add_versions("v4.0.8", "f808b26d8c3a59def27fea207182ece77a8930bd121a69f80d328ecf3cfef925")
    add_versions("v4.0.6", "6920a6a5d6a04b9a89b2a89af7132f8acefd46e0c2a7b190350539e9213816c0")
    add_versions("v4.0.5", "ffc668a310e77607d393f3c18b32715f223da1eac4c4d6e0579a11df8e6b59cf")
    add_versions("v4.0.4", "7c8a403d0c575d52473c8644cd9eb46c6ba028d2549bc3e0cdc2d45f5cfd78a0")
    add_versions("v4.0.3", "05e7d023b2bf606777442efc49038e0efce317596582db15adf5c776e237a326")
    add_versions("v4.0.2", "d3c032650cd30823b7ebbebbe91f39d8c0e91221b2e3e92b93ca425478f986f2")
    add_versions("v4.0.1", "9014342a716258da00b97bf8c201a2edc4d72d2025cd8d62f0650ac627038f95")
    add_versions("v4.0.0", "ac44d9652aa2ee64d405c1705718f26b385337a9b8cf20bf2b2aac6435a16c1e")
    add_versions("v3.2.5", "14fd1b3c466814cb4c40771b7f207b61d2c7a0aa6a5e620ca05c00df27f25afd")
    add_versions("v3.2.4", "fde21a4c519eed25f095a1cd8490167409cc70d7b5e9c38756142e588ccb7c7e")
    add_versions("v3.2.3", "3ba9b0dbbff08767bdffe8f03b10e596ca351228862722e4c9d4d126d2865250")
    add_versions("v3.2.1", "8d6aa7d77ad0abb35bb6139cb9a33597ac4c5b33da6a004ae42429b8598c9605")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::utf8cpp")
    elseif is_plat("linux") then
        add_extsources("apt::libutfcpp-dev", "pacman::utf8cpp")
    elseif is_plat("macosx") then
        add_extsources("brew::utf8cpp")
    end

    add_deps("cmake")

    add_includedirs("include", "include/utf8cpp")

    on_install(function (package)
        local configs = {"-DUTF8_TESTS=OFF", "-DUTF8_INSTALL=ON", "-DUTF8_SAMPLES=OFF"}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local test_snippet = [[
            #define UTF_CPP_CPLUSPLUS 201103L
            #include <utf8.h>
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
