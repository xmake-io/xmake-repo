package("autoconf-archive")
    set_homepage("http://www.gnu.org/software/autoconf-archive/")
    set_description("A mirror of the GNU Autoconf Archive, a collection of more than 500 macros for GNU Autoconf that have been contributed as free software by friendly supporters of the cause from all over the Internet.")
    set_license("GPL-3.0-or-later")

    add_urls("https://ftp.gnu.org/gnu/autoconf-archive/autoconf-archive-$(version).tar.xz",
             "https://ftpmirror.gnu.org/autoconf-archive/autoconf-archive-$(version).tar.xz")
    add_versions("2023.02.20", "71d4048479ae28f1f5794619c3d72df9c01df49b1c628ef85fde37596dc31a33")

    add_deps("autoconf")

    on_install("@macosx", "@linux", "@bsd", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        io.writefile("test.m4", [[
      AC_INIT(myconfig, version-0.1)
      AC_MSG_NOTICE([Hello, world.])

      AX_HAVE_SELECT(
        [AX_CONFIG_FEATURE_ENABLE(select)],
        [AX_CONFIG_FEATURE_DISABLE(select)])
      AX_CONFIG_FEATURE(
        [select], [This platform supports select(7)],
        [HAVE_SELECT], [This platform supports select(7).])
    EOS]])
        os.vrun("autoconf test.m4")
    end)
