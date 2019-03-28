package("bzip2")

    set_homepage("https://en.wikipedia.org/wiki/Bzip2")
    set_description("Freely available high-quality data compressor.")

    set_urls("https://ftp.osuosl.org/pub/clfs/conglomeration/bzip2/bzip2-$(version).tar.gz",
             "https://fossies.org/linux/misc/bzip2-$(version).tar.gz")
    add_versions("1.0.6", "a2848f34fcd5d6cf47def00461fcb528a0484d8edef8208d6d2e2909dc61d9cd")

    on_load("windows", function (package)
        package:addenv("PATH", "bin")
        package:add("links", "libbz2")
    end)

    on_install("windows", function (package)
        io.gsub("makefile.msc", "%-MD", "-" .. package:config("vs_runtime"))
        os.vrunv("nmake", {"-f", "makefile.msc"})
        os.cp("libbz2.lib", package:installdir("lib"))
        os.cp("*.h", package:installdir("include"))
        os.cp("*.exe", package:installdir("bin"))
    end)

    on_install("macosx", "linux", function (package)
        os.vrunv("make", {"install", "PREFIX=" .. package:installdir()})
    end)

    on_test(function (package)
        os.vrun("bzip2 --help")
        assert(package:has_cfuncs("BZ2_bzCompressInit", {includes = "bzlib.h"}))
    end)
