package("lazy_importer")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/JustasMasiulis/lazy_importer")
    set_description("library for importing functions from dlls in a hidden, reverse engineer unfriendly way")
    set_license("Apache-2.0")

    add_urls("https://github.com/JustasMasiulis/lazy_importer.git")

    add_versions("2023.08.02", "4810f51d63438865e508c2784ea00811d9beb2ea")

    on_install("windows", "mingw", "msys", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("lazy_importer.hpp"))
    end)
