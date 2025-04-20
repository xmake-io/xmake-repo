package("sfl-library")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/slavenf/sfl-library")
    set_description("C++11 header-only library. Small and static vector. Small and static flat map/set. Compact vector. Segmented vector.")
    set_license("zlib")

    add_urls("https://github.com/slavenf/sfl-library/archive/refs/tags/$(version).tar.gz",
             "https://github.com/slavenf/sfl-library.git")

    add_versions("1.6.0", "f5121d95c2f3922da4f1cec9bb6045d8733892ddc55ee3c47c99e761e5df5ec4")
    add_versions("1.5.0", "767d9b3627540071d2a80f18f034d80d6e9eaffc027876c7898c51aeebd3bf37")

    on_install(function (package)
        os.vcp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("sfl::small_vector<int, 4>", {configs = {languages = "c++11"}, includes = "sfl/small_vector.hpp"}))
    end)
