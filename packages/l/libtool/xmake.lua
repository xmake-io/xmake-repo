package("libtool")

    set_kind("binary")
    set_homepage("https://www.gnu.org/software/libtool/")
    set_description("A generic library support script.")

    add_urls("http://ftpmirror.gnu.org/libtool/libtool-$(version).tar.gz",
             "https://mirrors.ustc.edu.cn/gnu/libtool/libtool-$(version).tar.gz",
             "git://git.savannah.gnu.org/libtool.git")
    add_versions("2.4.6", "e3bd4d5d3d025a36c21dd6af7ea818a2afcd4dfc1ea5a17b39d7854bcd0c06e3")
    add_versions("2.4.5", "509cb49c7de14ce7eaf88993cf09fd4071882699dfd874c2e95b31ab107d6987")
    add_versions("2.4.7", "04e96c2404ea70c590c546eba4202a4e12722c640016c12b9b2f1ce3d481e9a8")

    if is_host("linux") then
        add_extsources("apt::libtool", "pacman::libtool")
    end

    add_deps("autoconf")

    on_install("@macosx", "@linux", "@bsd", function (package)
        import("package.tools.autoconf").install(package, {"--disable-dependency-tracking", "--enable-ltdl-install"})
    end)

    on_test(function (package)
        os.vrun("libtool --version")
    end)
