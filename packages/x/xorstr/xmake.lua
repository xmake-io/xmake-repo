package("xorstr")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/JustasMasiulis/xorstr")
    set_description("heavily vectorized c++17 compile time string encryption.")
    set_license("Apache-2.0")

    add_urls("https://github.com/JustasMasiulis/xorstr/archive/8ab293225374e16cbae9a54b6a1bed3ee0bf9681.tar.gz",
             "https://github.com/JustasMasiulis/xorstr.git")

    add_versions("2021.11.19", "b52220a50c33f8b13e6aaa2fcd14f31a44d96ba721b014ab921c30b5e3cb61eb")

    on_install("!cross and !wasm and mingw|!i386", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #define JM_XORSTR_DISABLE_AVX_INTRINSICS
            #include <xorstr.hpp>
            void test() {
                xorstr_("hello world");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
