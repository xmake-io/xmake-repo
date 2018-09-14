package("sqlite3")

    set_homepage("https://sqlite.org/")
    set_description("The most used database engine in the world")

    set_urls("https://sqlite.org/2018/sqlite-autoconf-3240000.tar.gz",
             "https://sqlite.org/2018/sqlite-autoconf-3230000.tar.gz")

    add_versions("3.24.0", "d9d14e88c6fb6d68de9ca0d1f9797477d82fc3aed613558f87ffbdbbc5ceb74a")
    add_versions("3.23.0", "b7711a1800a071674c2bf76898ae8584fc6c9643cfe933cfc1bc54361e3a6e49")

    on_build("windows", function (package)
        os.vrun("nmake DEBUG=%s -f Makefile.msc", is_mode("debug") and "1" or "0")
    end)

    on_install("windows", function (package)
        os.cp("*.h", package:installdir("include"))
        os.cp("sqlite3.lib", package:installdir("lib"))
        os.cp("sqlite3.pdb", package:installdir("lib"))
        os.cp("sqlite3.dll", package:installdir("lib"))
        os.cp("sqlite3.def", package:installdir("lib"))
    end)

    on_build("macosx", "linux", function (package)
        os.vrun("./configure --prefix=%s %s", package:installdir(), is_mode("debug") and "--enable-debug" or "")
        os.vrun("make")
    end)

    on_install("macosx", "linux", function (package)
        os.vrun("make install")
    end)
