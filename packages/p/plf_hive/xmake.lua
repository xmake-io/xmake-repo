package("plf_hive")
    set_kind("library", {headeronly = true})
    set_homepage("https://plflib.org/colony.htm")
    set_description("plf::hive is a fork of plf::colony to match the current C++ standards proposal.")
    set_license("zlib")

    add_urls("https://github.com/mattreecebentley/plf_hive.git")
    add_versions("2024.04.21", "7689475b1fa2a95228cf0f44db9c209d7e430748")

    on_install(function (package)
        os.cp("plf_hive.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("plf::hive<int>", {configs = {languages = "c++20"}, includes = "plf_hive.h"}))
    end)
