package("quadsort")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/scandum/quadsort")
    set_description("Quadsort is a branchless stable adaptive mergesort faster than quicksort.")
    set_license("MIT")

    add_urls("https://github.com/scandum/quadsort.git")
    add_versions("2023.02.03", "7b4e7b1489ab1c80eb97a90ae01deada7c740a46")

    on_install(function (package)
        os.cp("src/quadsort.c", package:installdir("include"))
        os.cp("src/quadsort.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("quadsort", {includes = "quadsort.h"}))
    end)
