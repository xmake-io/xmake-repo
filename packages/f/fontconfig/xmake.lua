package("fontconfig")

    set_homepage("https://www.freedesktop.org/wiki/Software/fontconfig/")
    set_description("A library for configuring and customizing font access.")

    set_urls("https://www.freedesktop.org/software/fontconfig/release/fontconfig-$(version).tar.gz")
    add_versions("2.13.1", "9f0d852b39d75fc655f9f53850eb32555394f36104a044bb2b2fc9e66dbbfa7f")

    add_deps("freetype")

    on_install("linux", "macosx", function (package)
        import("package.tools.autoconf").install(package)
    end)
