package("plf_nanotimer")
    set_kind("library", {headeronly = true})
    set_homepage("https://plflib.org/nanotimer.htm")
    set_description("A cross-platform lowest-overhead microsecond-precision timer for simple benchmarking on Linux/BSD/Windows/Mac.")
    set_license("zlib")

    add_urls("https://github.com/mattreecebentley/plf_nanotimer.git")
    add_versions("v1.07", "55e0fcb135ec8db874a0656f94d1f1780d7c75a7")

    on_install(function (package)
        os.cp("plf_nanotimer.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <plf_nanotimer.h>
            void test() {
                plf::nanotimer timer;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
