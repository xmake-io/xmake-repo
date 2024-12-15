package("itstool")
    set_kind("binary")
    set_homepage("http://itstool.org/")
    set_description("ITS Tool allows you to translate your XML documents with PO files")
    set_license("GPL-3.0")

    add_urls("https://github.com/itstool/itstool.git")
    add_urls("http://files.itstool.org/itstool/itstool-$(version).tar.bz2")

    add_versions("2.0.7", "6b9a7cd29a12bb95598f5750e8763cee78836a1a207f85b74d8b3275b27e87ca")

    add_deps("libxml2", {configs = {python = true}})

    on_install("linux", "macosx", "bsd", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        os.vrun("itstool --version")
    end)
