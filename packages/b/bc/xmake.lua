package("bc")

    set_kind("binary")
    set_homepage("https://www.gnu.org/software/bc/")
    set_description("Arbitrary precision numeric processing language")
    set_license("GPL-3.0-or-later")

    set_urls("https://ftpmirror.gnu.org/bc/bc-$(version).tar.gz",
             "https://ftp.gnu.org/gnu/bc/bc-$(version).tar.gz")
    add_versions("1.07.1", "62adfca89b0a1c0164c2cdca59ca210c1d44c3ffc46daf9931cf4942664cb02a")

    add_deps("flex", "bison", "ed", "texinfo")

    on_install("linux", "macosx", function (package)
        local configs = {
            "--disable-dependency-tracking",
            "--disable-install-warnings",
            "--disable-debug",
            "--infodir=" .. package:installdir("info"),
            "--mandir=" .. package:installdir("man")}
        if package:is_plat("macosx") then
            table.insert(configs, "--with-libedit")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("bc --version")
    end)
