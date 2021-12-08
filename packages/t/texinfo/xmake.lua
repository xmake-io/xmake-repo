package("texinfo")

    set_kind("binary")
    set_homepage("https://www.gnu.org/software/texinfo/")
    set_description("Official documentation format of the GNU project")
    set_license("GPL-3.0")

    set_urls("https://ftp.gnu.org/gnu/texinfo/texinfo-$(version).tar.xz",
             "https://ftpmirror.gnu.org/texinfo/texinfo-$(version).tar.xz")
    add_versions("6.8", "8eb753ed28bca21f8f56c1a180362aed789229bd62fff58bf8368e9beb59fec4")

    on_install("linux", "macosx", function (package)
        local configs = {"--disable-dependency-tracking", "--disable-install-warnings"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        os.exec("makeinfo --version")
    end)
