package("qoa")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/phoboslab/qoa")
    set_description("The “Quite OK Audio Format” for fast, lossy audio compression")
    set_license("MIT")

    add_urls("https://github.com/phoboslab/qoa.git")

    add_versions("2024.07.02", "e0c69447d4d3945c3c92ac1751e4cdc9803a8303")

    on_install(function (package)
        os.cp("qoa.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("qoa_encode_header", {includes = "qoa.h"}))
    end)
