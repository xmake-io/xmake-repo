package("zlib")

    set_homepage("http://www.zlib.net")
    set_description("A Massively Spiffy Yet Delicately Unobtrusive Compression Library")

    set_urls("http://zlib.net/zlib-$(version).tar.gz",
             "https://downloads.sourceforge.net/project/libpng/zlib/$(version)/zlib-$(version).tar.gz")

    add_versions("1.2.10", "8d7e9f698ce48787b6e1c67e6bff79e487303e66077e25cb9784ac8835978017")
    add_versions("1.2.11", "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1")

    on_build("macosx", "linux", function (package)
        os.vrun("./configure --prefix=%s", package:installdir())
        os.vrun("make")
    end)

    on_build("windows", function (package)
        os.vrun("nmake -f win32\\Makefile.msc zlib.lib")
    end)

    on_install("macosx", "linux", function (package)
        os.vrun("make install")
    end)

    on_install("windows", function (package)
        os.cp("zlib.lib", package:installdir("lib"))
        os.cp("*.h", package:installdir("include"))
    end)
