package("csv2")
    set_kind("library", {headeronly = true}) 
    set_homepage("https://github.com/p-ranav/csv2")
    set_description("A CSV parser library")
    set_license("MIT")

    add_urls("https://github.com/p-ranav/csv2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/p-ranav/csv2.git")
    add_versions("v0.1", "e185d0378a95edb2ad0f2473970d8fe8579c87326640340d42bdf6327fd96791")

    on_install(function (package)
        os.cp("include/csv2", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("csv2::Reader<csv2::delimiter<','>, csv2::quote_character<'\"'>, csv2::first_row_is_header<false>>", 
            {configs = {languages = "c++11"}, includes = "csv2/reader.hpp"}))
    end)
