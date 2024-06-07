package("hffix")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/jamesdbrock/hffix")
    set_description("C++ Library for FIX (Financial Information Exchange) Protocol.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/jamesdbrock/hffix/archive/refs/tags/$(version).zip",
             "https://github.com/jamesdbrock/hffix.git")
    add_versions("v1.4.1", "3938243ad50ce9523cacaabc1fef09db8f3e514b846497ab3246f390a72dabe0")
    add_versions("v1.4.0", "b0dd5dfc5892b7336304274a4334d849d5b6778f0de2f7c2728957cdf2d9beed")
    add_versions("v1.1.0", "7646ddb8ca19da31a8835b64493100a0f2239c28980f590918e0b5bfab4d736d")

    on_install("linux", "macosx", "bsd", function (package)
        os.cp("include/*.hpp", package:installdir("include/hffix"))
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("hffix::message_reader", {configs = {languages = "c++11"}, includes = "hffix/hffix.hpp"}))
    end)
