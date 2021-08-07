package("bison")

    set_kind("binary")
    set_homepage("https://www.gnu.org/software/bison/")
    set_description("A general-purpose parser generator.")
    set_license("GPL-3.0")

    add_urls("http://ftp.gnu.org/gnu/bison/bison-$(version).tar.gz")
    add_versions("3.7.4", "fbabc7359ccd8b4b36d47bfe37ebbce44805c052526d5558b95eda125d1677e2")
    add_versions("3.7.6", "69dc0bb46ea8fc307d4ca1e0b61c8c355eb207d0b0c69f4f8462328e74d7b9ea")

    if is_plat("linux") then
        add_deps("m4")
    end

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package)
        os.rm(package:installdir("share", "doc"))
    end)

    on_test(function (package)
        os.vrun("bison -h")
    end)
