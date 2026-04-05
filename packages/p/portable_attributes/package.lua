package("portable_attributes")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/mtueih/portable_attributes")
    set_description("Portable C function attributes (GCC/Clang/MSVC)")
    set_license("MIT")

    add_urls("https://github.com/mtueih/portable_attributes/archive/refs/tags/$(version).tar.gz")

    add_versions("1.0.0", "52fc80e097c6ec4a396ae225c78c7740a6740982c312d7fe97ffd33cb5f3a1f1")

    on_install(function (package)
        os.cp("include/portable_attributes.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("NODISCARD", {includes = "portable_attributes.h"}))
    end)