package("quadsort")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/scandum/quadsort")
    set_description("Quadsort is a branchless stable adaptive mergesort faster than quicksort.")
    set_license("MIT")

    add_urls("https://github.com/scandum/quadsort.git")
    add_versions("2023.02.03", "45432056f47137624aa28a07cdf62c5b561575dd")

    on_install(function (package)
        os.cp("src/quadsort.c", package:installdir("include"))
        os.cp("src/quadsort.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("quadsort", {includes = "quadsort.h"}))
    end)
