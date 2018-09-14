package("pcre")

    set_homepage("https://www.pcre.org/")
    set_description("A Perl Compatible Regular Expressions Library")

    set_urls("https://ftp.pcre.org/pub/pcre/pcre-$(version).zip",
             "ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$(version).zip")

    add_versions("8.40", "99e19194fa57d37c38e897d07ecb3366b18e8c395b36c6d555706a7f1df0a5d4")
    add_versions("8.41", "0e914a3a5eb3387cad6ffac591c44b24bc384c4e828643643ebac991b57dfcc5")

    if is_host("windows") then
        add_deps("cmake")
    end

    on_build("windows", function (package)
        import("package.builder.cmake").build(package)
    end)

    on_install("windows", function (package)
        import("package.builder.cmake").install(package)
    end)

    on_build("macosx", "linux", function (package)
        os.vrun("./configure --prefix=%s", package:installdir())
        os.vrun("make")
    end)

    on_install("macosx", "linux", function (package)
        os.vrun("make install")
    end)
