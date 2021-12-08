package("ed")

    set_kind("binary")
    set_homepage("https://www.gnu.org/software/ed/ed.html")
    set_description("Classic UNIX line editor")
    set_license("GPL-3.0-or-later")

    set_urls("https://github.com/xmake-mirror/ed/archive/refs/tags/$(version).tar.gz")
    add_versions("1.17", "990129f9ebe21f0a1d880f2b71a33a3bf384eccae37c2dcd80419296f6bd02c6")


    on_install("linux", "macosx", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        os.vrun("ed --version")
    end)
