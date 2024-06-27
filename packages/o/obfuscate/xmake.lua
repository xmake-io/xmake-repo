package("obfuscate")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/adamyaxley/Obfuscate")
    set_description("Guaranteed compile-time string literal obfuscation header-only library for C++14")
    set_license("Unlicense")

    add_urls("https://github.com/adamyaxley/Obfuscate.git")
    add_versions("2024.02.11", "e65173d617983ce6b714c9ade5a6dbf3503c9a96")

    on_install(function (package)
        os.cp("obfuscate.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                AY_OBFUSCATE("Hello World");
            }
        ]]}, {configs = {languages = "cxx14"}, includes = "obfuscate.h"}))
    end)
