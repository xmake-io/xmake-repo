package("freetype")

    set_homepage("https://www.freetype.org")
    set_description("A freely available software library to render fonts.")

    if is_plat("windows") then
        set_urls("https://github.com/ubawurinna/freetype-windows-binaries/releases/download/v$(version)/freetype-$(version).zip")
        add_versions("2.9.1", "5238a18447b6611e8838d23c42174e5429b730b91c5aa3747b3eb4e3fc0720a7")
    else
        set_urls("https://download.savannah.gnu.org/releases/freetype/freetype-$(version).tar.gz")
        add_versions("2.9.1", "ec391504e55498adceb30baceebd147a6e963f636eb617424bcfc47a169898ce")
    end

    on_install("windows", function (package)
        os.cp("include", package:installdir())
        os.cp(is_arch("x64") and "win64/*" or "win32/*", package:installdir("lib"))
    end)

    on_install("linux", "macosx", function (package)
        import("package.tools.autoconf").install(package)
    end)
