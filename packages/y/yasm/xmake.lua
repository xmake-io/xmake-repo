package("yasm")

    set_kind("binary")
    set_homepage("https://yasm.tortall.net/")
    set_description("Modular BSD reimplementation of NASM.")

    add_urls("https://www.tortall.net/projects/yasm/releases/yasm-$(version).tar.gz",
             "https://ftp.openbsd.org/pub/OpenBSD/distfiles/yasm-$(version).tar.gz")
    add_versions("1.3.0", "3dce6601b495f5b3d45b59f7d2492a340ee7e84b5beca17e48f862502bd5603f")

    on_install("@linux", "@macosx", function (package)
        local configs = {"--disable-python"}
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        os.vrun("yasm --version")
    end)
