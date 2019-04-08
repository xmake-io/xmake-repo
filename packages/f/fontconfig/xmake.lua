package("fontconfig")

    set_homepage("https://www.freedesktop.org/wiki/Software/fontconfig/")
    set_description("A library for configuring and customizing font access.")

    set_urls("https://www.freedesktop.org/software/fontconfig/release/fontconfig-$(version).tar.gz")
    add_versions("2.13.1", "9f0d852b39d75fc655f9f53850eb32555394f36104a044bb2b2fc9e66dbbfa7f")

    add_deps("pkg-config", "freetype >= 2.9")
    if not is_plat("macosx") then
        add_deps("autoconf", "automake", "gperf", "bzip2")
    end
 
    on_install("linux", "macosx", function (package)
        local font_dirs = {}
        if is_plat("macosx") then
            table.insert(font_dirs, "/System/Library/Fonts")
            table.insert(font_dirs, "/Library/Fonts")
            table.insert(font_dirs, "~/Library/Fonts")
        end
        local configs = {"--disable-dependency-tracking", "--disable-silent-rules", "--enable-static", "--disable-docs"}
        if #font_dirs > 0 then
            table.insert(configs, "--with-add-fonts=" .. table.concat(font_dirs, ','))
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("FcInitLoadConfigAndFonts", {includes = "fontconfig/fontconfig.h"}))
    end)
