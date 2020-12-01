package("bison")

    set_homepage("https://www.gnu.org/software/bison/")
    set_description("A general-purpose parser generator.")
    set_license("GPL-3.0")

    add_urls("http://ftp.gnu.org/gnu/bison/bison-$(version).tar.gz")
    add_versions("3.7.4", "fbabc7359ccd8b4b36d47bfe37ebbce44805c052526d5558b95eda125d1677e2")

    set_kind("binary")
    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package)
        os.rm(package:installdir("share", "doc"))
    end)

    on_test(function (package)
        os.vrun("bison -h")
    end)
