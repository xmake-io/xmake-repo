package("obfusheader.h")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/ac3ss0r/obfusheader.h")
    set_description("Obfusheader.h is a portable header file for C++14 compile-time obfuscation.")
    set_license("Apache-2.0")

    add_urls("https://github.com/ac3ss0r/obfusheader.h.git")
    add_versions("2024.08.19", "cbd87b0edd2695764d08110cf5a192b193218aef")

    on_install(function (package)
        os.vcp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cstddef>
            #include <obfusheader.h>
            void test() {
                const char* str = OBF("test");
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
