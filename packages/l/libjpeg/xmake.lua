package("libjpeg")

    set_homepage("http://ijg.org/")
    set_description("A widely used C library for reading and writing JPEG image files.")

    set_urls("http://www.ijg.org/files/jpegsrc.$(version).tar.gz")

    add_versions("v9c", "650250979303a649e21f87b5ccd02672af1ea6954b911342ea491f351ceb7122")
    add_versions("v9b", "240fd398da741669bf3c90366f58452ea59041cacc741a489b99f2f6a0bad052")

    on_build("windows", function (package)
        os.mv("jconfig.vc", "jconfig.h")
        os.vrun("nmake -f makefile.vc")
    end)

    on_install("windows", function (package)
        os.cp("*.h", package:installdir("include"))
        os.cp("libjpeg.lib", package:installdir("lib"))
    end)

    on_build("macosx", "linux", function (package)
        os.vrun("./configure --prefix=%s", package:installdir())
        os.vrun("make")
    end)

    on_install("macosx", "linux", function (package)
        os.vrun("make install")
    end)
