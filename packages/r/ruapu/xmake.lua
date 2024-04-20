package("ruapu")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/nihui/ruapu")
    set_description("Detect CPU features with single-file")
    set_license("MIT")

    add_urls("https://github.com/nihui/ruapu/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nihui/ruapu.git")

    add_versions("0.1.0", "65fd826ed1772717d4cee70b6620277df0328408612f7643658a0064f1a163ff")

    on_install(function (package)
        os.cp("ruapu.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ruapu_init", {includes = "ruapu.h", defines = "RUAPU_IMPLEMENTATION"}))
    end)
