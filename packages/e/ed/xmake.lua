package("ed")

    set_kind("binary")
    set_homepage("https://www.gnu.org/software/ed/ed.html")
    set_description("Classic UNIX line editor")
    set_license("GPL-3.0-or-later")

    set_urls("https://ftp.gnu.org/gnu/ed/ed-$(version).tar.lz",
             "https://ftpmirror.gnu.org/ed/ed-$(version).tar.lz")
    add_versions("1.17", "71de39883c25b6fab44add80635382a10c9bf154515b94729f4a6529ddcc5e54")


    on_install("linux", "macosx", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        os.exec("ed --version")
    end)
