package("stringzilla")
    set_kind("library", {headeronly = true})
    set_homepage("https://ashvardanian.com/posts/stringzilla/")
    set_description("Up to 10x faster string search, split, sort, and shuffle for long strings and multi-gigabyte files in Python and C, leveraging SIMD with just a few lines of Arm Neon and x86 AVX2 & AVX-512 intrinsics 🦖")
    set_license("Apache-2.0")

    add_urls("https://github.com/ashvardanian/StringZilla/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ashvardanian/StringZilla.git")

    add_versions("v1.2.2", "2e17c49965841647a1c371247f53b2f576e5fb32fe4b84a080d425b12f17703c")

    on_install("windows|x64", "linux|x86_64", "mingw|x86_64", "msys", function (package)
        os.cp("stringzilla/stringzilla.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("strzl_sort", {includes = "stringzilla.h", configs = {languages = "c++17"}}))
    end)
