package("freetype")

    set_homepage("https://www.freetype.org")
    set_description("A freely available software library to render fonts.")

    if is_plat("windows") then
        set_urls("https://github.com/ubawurinna/freetype-windows-binaries/releases/download/v$(version)/freetype-$(version).zip")
        add_versions("2.9.1", "5238a18447b6611e8838d23c42174e5429b730b91c5aa3747b3eb4e3fc0720a7")
    else
        set_urls("https://downloads.sourceforge.net/project/freetype/freetype2/$(version)/freetype-$(version).tar.bz2",
                 "https://download.savannah.gnu.org/releases/freetype/freetype-$(version).tar.bz2")
        add_versions("2.9.1", "db8d87ea720ea9d5edc5388fc7a0497bb11ba9fe972245e0f7f4c7e8b1e1e84d")
    end

    if is_plat("windows") then
        add_includedirs("include/freetype")
    else
        add_includedirs("include/freetype2/freetype")
    end

    on_install("windows", function (package)
        os.cp("include", package:installdir())
        os.cp(is_arch("x64") and "win64/*" or "win32/*", package:installdir("lib"))
    end)

    on_install("linux", "macosx", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("FT_Init_FreeType", {includes = {"ft2build.h", "FT_FREETYPE_H"}}))
    end)
