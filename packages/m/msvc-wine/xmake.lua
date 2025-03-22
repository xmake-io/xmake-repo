package("msvc-wine")
    set_kind("toolchain")
    set_homepage("https://github.com/mstorsjo/msvc-wine")
    set_description("Scripts for setting up and running MSVC in Wine on Linux")

    add_urls("https://github.com/mstorsjo/msvc-wine.git")

    add_version("2025.03.02", "44dc13b5e62ecc2373fbe7e4727a525001f403f4")

    add_deps("python 3.x", {kind = "binary"})

    on_install("@linux", "@macosx", function (package)
        os.cp("*", package:installdir("bin"))
    end)

    on_test(function (package)
        assert(os.isfile(path.join(package:installdir("bin"), "vsdownload.py")))
    end)
