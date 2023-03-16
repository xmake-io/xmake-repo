package("tclsh")
    set_kind("binary")
    set_homepage("https://core.tcl-lang.org/tcl/")
    set_description("The Tcl Core. (Mirror of core.tcl-lang.org) ")

    add_urls("https://github.com/tcltk/tcl.git")
    add_versions("2023.03.14", "69fe4c9e803e72ef654111cbbf3ce184e63989d4")

    on_install("linux", "macosx", function (package)
        local configs = {}
        os.cd("unix")
        import("package.tools.autoconf").install(package, configs)
        os.cp(path.join(package:installdir("bin"), "tclsh9.0"), path.join(package:installdir("bin"), "tclsh"))
    end)

    on_install("windows", function (package)
        os.cd("win")
        -- TODO
        io.replace("makefile.vc", "libtclzip:  core dlls $(TCLSCRIPTZIP)", "libtclzip:  core dlls", {plain = true})
        import("package.tools.nmake").build(package, {"-f", "makefile.vc", "release"})
        os.cp("Release_*/*.exe", package:installdir("bin"))
        os.cp("Release_*/*.dll", package:installdir("bin"))
        os.cp(path.join(package:installdir("bin"), "tclsh90.exe"), path.join(package:installdir("bin"), "tclsh.exe"))
    end)

    on_test(function (package)
        local infile = os.tmpfile()
        local outfile = os.tmpfile()
        io.writefile(infile, "puts hello\n")
        local outdata = os.iorunv("tclsh", {infile})
        assert(outdata == "hello\n")
        os.rm(infile)
        os.rm(outfile)
    end)
