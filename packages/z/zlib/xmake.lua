package("zlib")

    set_homepage("http://www.zlib.net")
    set_description("A Massively Spiffy Yet Delicately Unobtrusive Compression Library")

    add_urls("https://github.com/madler/zlib/archive/v$(version).tar.gz")

    add_versions("1.2.10", "42cd7b2bdaf1c4570e0877e61f2fdc0bce8019492431d054d3d86925e5058dc5")
    add_versions("1.2.11", "629380c90a77b964d896ed37163f5c3a34f6e6d897311f1df2a7016355c45eff")

    on_install("windows", function (package)
        io.gsub("win32/Makefile.msc", "%-MD", "-" .. package:config("vs_runtime"))
        import("package.tools.nmake").build(package, {"-f", "win32\\Makefile.msc", "zlib.lib"})
        os.cp("zlib.lib", package:installdir("lib"))
        os.cp("*.h", package:installdir("include"))
    end)

    on_install("mingw@msys", function (package)
        io.gsub("win32/Makefile.gcc", "\nCC =.-\n",      "\nCC=" .. (package:build_getenv("cc") or "") .. "\n")
        io.gsub("win32/Makefile.gcc", "\nAR =.-\n",      "\nAR=" .. (package:build_getenv("ar") or "") .. "\n")
        import("package.tools.make").build(package, {"-f", "win32/Makefile.gcc", "libz.a"})
        os.cp("libz.a", package:installdir("lib"))
        os.cp("*.h", package:installdir("include"))
    end)

    on_install("macosx", "bsd", function (package)
        import("package.tools.autoconf").install(package, {"--static"})
    end)

    on_install("linux", function (package)
        import("package.tools.autoconf").configure(package, {"--static"})
        io.gsub("Makefile", "\nCFLAGS=(.-)\n", "\nCFLAGS=%1 -fPIC\n")
        os.vrun("make install -j4")
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
