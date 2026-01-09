package("xmllint")
    set_kind("binary")
    set_homepage("http://xmlsoft.org/")
    set_description("The XML C parser and toolkit of Gnome.")
    set_license("MIT")

    add_urls("https://download.gnome.org/sources/libxml2/$(version).tar.xz", {
        version = function (version)
            return version:major() .. "." .. version:minor() .. "/libxml2-" .. version
        end
    })

    add_versions("2.15.1", "c008bac08fd5c7b4a87f7b8a71f283fa581d80d80ff8d2efd3b26224c39bc54c")

    add_deps("autotools")
    add_deps("zlib", "xz", "readline", "icu4c", "libiconv")

    on_install("@linux", "@macosx", "@mingw", function (package)
        local configs = {
            "--disable-dependency-tracking",
            "--with-history",
            "--with-iconv",
            "--with-legacy",
            "--with-http",
            "--without-icu",
            "--without-python",
            "--disable-docs",
            "--enable-shared",
            "--enable-static"
        }
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("xmllint --version")
    end)
