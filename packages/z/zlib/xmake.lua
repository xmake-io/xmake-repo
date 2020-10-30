package("zlib")

    set_homepage("http://www.zlib.net")
    set_description("A Massively Spiffy Yet Delicately Unobtrusive Compression Library")

    set_urls("http://zlib.net/zlib-$(version).tar.gz",
             "https://downloads.sourceforge.net/project/libpng/zlib/$(version)/zlib-$(version).tar.gz")

    add_versions("1.2.10", "8d7e9f698ce48787b6e1c67e6bff79e487303e66077e25cb9784ac8835978017")
    add_versions("1.2.11", "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1")

    on_install("windows", function (package)
        io.gsub("win32/Makefile.msc", "%-MD", "-" .. package:config("vs_runtime"))
        import("package.tools.nmake").build(package, {"-f", "win32\\Makefile.msc", "zlib.lib"})
        os.cp("zlib.lib", package:installdir("lib"))
        os.cp("*.h", package:installdir("include"))
    end)

    on_install("mingw@windows", function (package)
        if is_subhost("msys") then
            io.gsub("win32/Makefile.gcc", "\nCC =.-\n",      "\nCC=" .. (package:build_getenv("cc") or "") .. "\n")
            io.gsub("win32/Makefile.gcc", "\nAR =.-\n",      "\nAR=" .. (package:build_getenv("ar") or "") .. "\n")
            import("package.tools.make").build(package, {"-f", "win32/Makefile.gcc", "libz.a"})
            os.cp("libz.a", package:installdir("lib"))
            os.cp("*.h", package:installdir("include"))
        end
    end)

    on_install("linux", "macosx", function (package)
        import("package.tools.autoconf").install(package, {"--static"})
    end)

    on_install("iphoneos", "android@linux,macosx", "mingw@linux,macosx", "cross", function (package)
        import("package.tools.autoconf").configure(package, {host = "", "--static"})
        io.gsub("Makefile", "\nAR=.-\n",      "\nAR=" .. (package:build_getenv("ar") or "") .. "\n")
        io.gsub("Makefile", "\nARFLAGS=.-\n", "\nARFLAGS=cr\n")
        io.gsub("Makefile", "\nRANLIB=.-\n",  "\nRANLIB=\n")
        os.vrun("make install -j4")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("inflate", {includes = "zlib.h"}))
    end)
