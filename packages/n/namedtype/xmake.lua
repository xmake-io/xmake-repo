package("namedtype")

    set_homepage("https://github.com/joboccara/NamedType")
    set_description("C++ Library for FIX (Financial Information Exchange) Protocol.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/jamesdbrock/hffix/archive/refs/tags/$(version).zip",
             "https://github.com/jamesdbrock/hffix.git")
    add_versions("v1.1.0", "7646ddb8ca19da31a8835b64493100a0f2239c28980f590918e0b5bfab4d736d")

    on_install("linux", "macosx", "bsd", "mingw", "android", "iphoneos", function (package)
        os.cp("include/*.hpp", package:installdir("include/hffix"))
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("hffix::message_reader", {configs = {languages = "c++11"}, includes = "hffix/hffix.hpp"}))
    end)

