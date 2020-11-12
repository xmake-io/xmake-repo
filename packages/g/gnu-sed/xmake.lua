package("gnu-sed")

    set_kind("binary")
    set_homepage("https://www.gnu.org/software/sed/")
    set_description("GNU implementation of the famous stream editor.")
    set_license("GPL-3.0")

    set_urls("https://ftp.gnu.org/gnu/sed/sed-$(version).tar.xz",
             "https://ftpmirror.gnu.org/sed/sed-$(version).tar.xz")
    add_versions("4.8", "f79b0cfea71b37a8eeec8490db6c5f7ae7719c35587f21edb0617f370eeff633")

    on_install("macosx", "linux", function (package)
        local configs = {"--disable-dependency-tracking"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("sed --version")
        io.writefile("test.txt", "Hello world!")
        os.vrunv("sed", {"-i", "s/world/World/g", "test.txt"})
        assert(io.readfile("test.txt") == "Hello World!")
    end)
