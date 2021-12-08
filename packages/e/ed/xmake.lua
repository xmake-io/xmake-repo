package("ed")

    set_kind("binary")
    set_homepage("https://www.gnu.org/software/ed/ed.html")
    set_description("Classic UNIX line editor")
    set_license("GPL-3.0-or-later")

    set_urls("https://ftp.gnu.org/gnu/ed/ed-$(version).tar.gz",
             "https://ftpmirror.gnu.org/ed/ed-$(version).tar.gz")
    add_versions("1.17", "db36da85ee1a9d8bafb4b041bd4c8c11becba0c43ec446353b67045de1634fda")

    on_install("linux", "macosx", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        os.exec("ed --version")
    end)
