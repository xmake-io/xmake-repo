package("libpopcnt")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/kimwalisch/libpopcnt")
    set_description("🚀 Fast C/C++ bit population count library")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/kimwalisch/libpopcnt/archive/refs/tags/$(version).tar.gz",
             "https://github.com/kimwalisch/libpopcnt.git")

    add_versions("v3.1", "b4ea061f4c2e5385dff0dd032ad5a16c60dc0dd050391283afb463c0d62c19bd")

    on_install(function (package)
        os.cp("libpopcnt.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("popcnt", {includes = "libpopcnt.h"}))
    end)
