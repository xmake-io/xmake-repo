package("ppqsort")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/GabTux/PPQSort")
    set_description("Efficient implementation of parallel quicksort algorithm")

    add_urls("https://github.com/GabTux/PPQSort/archive/refs/tags/$(version).tar.gz",
             "https://github.com/GabTux/PPQSort.git")

    add_versions("v1.0.5", "39a973a680eb0af3bd0bdd5f4e9fa81d484915f3141e3a4568930647a328ba12")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        if package:has_cxxflags("-std=c++20") then
            assert(package:has_cxxincludes("ppqsort.h", {configs = {languages = "c++20"}}))
        else
            wprint("C++20 not supported by the current toolchain, skipping test.")
        end
    end)
