package("cosmocc")
    set_kind("toolchain")
    set_homepage("https://github.com/jart/cosmopolitan")
    set_description("build-once run-anywhere c library")

    add_urls("https://cosmo.zip/pub/cosmocc/cosmocc-$(version).zip",
             "https://github.com/xmake-mirror/cosmopolitan/releases/download/$(version)/cosmocc-$(version).zip")
    add_versions("3.2.4", "d2fa6dbf6f987310494581deff5b915dbdc5ca701f20f7613bb0dcf1de2ee511")

    on_install("macosx", "windows", "linux", function (package)
        os.cp("*", package:installdir())
    end)

    on_test(function (package)
        os.vrunv("cosmocc", {"--version"}, {shell = true})
    end)
