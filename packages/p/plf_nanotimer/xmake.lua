package("plf_nanotimer")
    set_kind("library", {headeronly = true})
    set_homepage("https://plflib.org/nanotimer.htm")
    set_description("A cross-platform lowest-overhead microsecond-precision timer for simple benchmarking on Linux/BSD/Windows/Mac.")
    set_license("zlib")

    add_urls("https://github.com/mattreecebentley/plf_nanotimer.git")
    add_versions("v1.07", "55e0fcb135ec8db874a0656f94d1f1780d7c75a7")

    on_install("!wasm", function (package)
        os.cp("plf_nanotimer.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("plf::nanotimer", {configs = {languages = "c++17"}, includes = "plf_nanotimer.h"}))
    end)
