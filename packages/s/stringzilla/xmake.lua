package("stringzilla")
    set_kind("library", {headeronly = true})
    set_homepage("https://ashvardanian.com/posts/stringzilla/")
    set_description("Up to 10x faster string search, split, sort, and shuffle for long strings and multi-gigabyte files in Python and C, leveraging SIMD with just a few lines of Arm Neon and x86 AVX2 & AVX-512 intrinsics 🦖")
    set_license("Apache-2.0")

    add_urls("https://github.com/ashvardanian/StringZilla/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ashvardanian/StringZilla.git")

    add_versions("v1.2.2", "2e17c49965841647a1c371247f53b2f576e5fb32fe4b84a080d425b12f17703c")
    add_versions("v2.0.3", "6b52a7b4eb8383cbcf83608eaa08e5ba588a378449439b73584713a16d8920e3")

    on_install(function (package)
        os.cp("stringzilla/stringzilla.h", package:installdir("include"))
    end)

    on_test(function (package)
        if package:version():gt("2.0.0") then
            assert(package:has_cfuncs("sz_sort", {includes = "stringzilla.h"}))
        else
            assert(package:has_cxxfuncs("strzl_sort", {includes = "stringzilla.h", configs = {languages = "c++17"}}))
        end
    end)
