package("ppqsort")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/GabTux/PPQSort")
    set_description("Efficient implementation of parallel quicksort algorithm")

    add_urls("https://github.com/GabTux/PPQSort/archive/refs/tags/$(version).tar.gz",
             "https://github.com/GabTux/PPQSort.git")

    add_versions("v1.0.6", "12d9c05363fa3d36f4916a78f1c7e237748dfe111ef44b8b7a7ca0f3edad44da")
    add_versions("v1.0.5", "39a973a680eb0af3bd0bdd5f4e9fa81d484915f3141e3a4568930647a328ba12")

    on_check(function (package)
        assert(package:has_cxxincludes("syncstream", {configs = {languages = "c++20"}}), "package(ppqsort): need <syncstream> header.")
        assert(package:has_cxxincludes("ranges", {configs = {languages = "c++20"}}), "package(ppqsort): need <ranges> header.")
    end)

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("ppqsort.h", {configs = {languages = "c++20"}}))
    end)
