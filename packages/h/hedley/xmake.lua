package("hedley")
    set_kind("library", {headeronly = true})
    set_homepage("https://nemequ.github.io/hedley/")
    set_description("A C/C++ header to help move #ifdefs out of your code")
    set_license("CC0-1.0")

    add_urls("https://github.com/nemequ/hedley/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nemequ/hedley.git")

    add_versions("v15", "e91c71b58f59d08c7b8289be8f687866863d934dfaa528e4be30b178139ae863")

    on_install(function (package)
        os.cp("hedley.h", package:installdir("include/hedley"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <hedley/hedley.h>
            HEDLEY_NO_RETURN
            void test() {}
        ]]}))
    end)
