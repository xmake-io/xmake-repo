package("cute_headers")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/RandyGaul/cute_headers")
    set_description("Collection of cross-platform one-file C/C++ libraries with no dependencies, primarily used for games")
    set_license("Public Domain")

    add_urls("https://github.com/RandyGaul/cute_headers.git")
    add_versions("2024.07.22", "cab36d7c6690e334720e705bd6cd3ce29b0b0844")

    on_install(function (package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cute_aseprite_load_from_file", {includes = "cute_aseprite.h", defines = "CUTE_ASEPRITE_IMPLEMENTATION"}))
    end)