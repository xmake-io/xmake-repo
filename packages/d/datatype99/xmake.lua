package("datatype99")
    set_kind("library", { headeronly = true })
    set_homepage("https://github.com/Hirrolot/datatype99")
    set_description("Algebraic data types for C99")
    set_license("MIT")

    add_urls("https://github.com/Hirrolot/datatype99/archive/refs/tags/v$(version).tar.gz",
        "https://github.com/Hirrolot/datatype99.git")

    add_versions("1.6.3", "0ddc138eac8db19fa22c482d9a2ec107ff622fd7ce61bb0b1eefb4d8f522e01e")
    add_versions("1.6.4", "f8488decc7ab035e3af77ee62e64fc678d5cb57831457f7270efe003e63d6f09")

    add_deps("metalang99")

    on_install(function(package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function(package)
        assert(package:has_cincludes("datatype99.h"))
    end)
