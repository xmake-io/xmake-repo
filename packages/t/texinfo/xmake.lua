package("texinfo")
    set_kind("binary")
    set_homepage("https://www.gnu.org/software/texinfo/")
    set_description("Official documentation format of the GNU project")
    set_license("GPL-3.0")

    set_urls("https://ftpmirror.gnu.org/texinfo/texinfo-$(version).tar.xz",
             "https://ftp.gnu.org/gnu/texinfo/texinfo-$(version).tar.xz")

    add_versions("7.2", "0329d7788fbef113fa82cb80889ca197a344ce0df7646fe000974c5d714363a6")
    add_versions("6.7", "988403c1542d15ad044600b909997ba3079b10e03224c61188117f3676b02caa")
    -- FIXME, we need fix gnulib on linux, @see https://www.mail-archive.com/bug-texinfo@gnu.org/msg10181.html
    --add_versions("6.8", "8eb753ed28bca21f8f56c1a180362aed789229bd62fff58bf8368e9beb59fec4")

    on_install("linux", "macosx", "cross", function (package)
        local configs = {"--disable-dependency-tracking", "--disable-install-warnings"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("makeinfo --version")
    end)
