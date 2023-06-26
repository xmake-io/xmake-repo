package("fluxsort")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/scandum/fluxsort")
    set_description("A branchless stable quicksort / mergesort hybrid.")
    set_license("MIT")

    add_urls("https://github.com/scandum/fluxsort.git")
    add_versions("2023.02.05", "de6041a9772eed62db5fd2c664b3294ea3037b4b")

    on_install(function (package)
        os.cp("src/fluxsort.c", package:installdir("include"))
        os.cp("src/fluxsort.h", package:installdir("include"))
        os.cp("src/quadsort.c", package:installdir("include"))
        os.cp("src/quadsort.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("fluxsort", {includes = "fluxsort.h"}))
    end)
