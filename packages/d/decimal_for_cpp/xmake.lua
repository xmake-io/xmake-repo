package("decimal_for_cpp")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/vpiotr/decimal_for_cpp")
    set_description("Decimal data type support, for COBOL-like fixed-point operations on currency/money values.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/vpiotr/decimal_for_cpp.git")

    add_versions("1.20", "ad4f8f6cfe5096d7576d6ca782795c584abc1053")
    add_versions("1.19", "2bcf48af509690579cf2b521af46e7fb0157c8da")

    on_install(function (package)
        os.cp("include/*.h", package:installdir("include/decimal_for_cpp"))
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("dec::decimal<2>", {configs = {languages = "c++11"}, includes = "decimal_for_cpp/decimal.h"}))
    end)
