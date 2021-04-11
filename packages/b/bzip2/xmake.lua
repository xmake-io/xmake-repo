package("bzip2")

    set_homepage("https://sourceware.org/bzip2/")
    set_description("Freely available, patent free, high-quality data compressor.")

    add_urls("https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz")
    add_versions("1.0.8", "ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269")

    on_load("windows", function (package)
        package:add("links", "libbz2")
    end)

    on_install("windows", function (package)
        package:addenv("PATH", "bin")
        io.gsub("makefile.msc", "%-MD", "-" .. package:config("vs_runtime"))
        import("package.tools.nmake").build(package, {"-f", "makefile.msc", "bzip2"})
        os.cp("libbz2.lib", package:installdir("lib"))
        os.cp("*.h", package:installdir("include"))
        os.cp("*.exe", package:installdir("bin"))
    end)

    on_install("macosx", "linux", function (package)
        package:addenv("PATH", "bin")
        local configs = {}
        if package:config("pic") ~= false then
            table.insert(configs, "CFLAGS=-fPIC")
        end
        io.gsub("Makefile", "PREFIX=.-\n", "PREFIX=" .. package:installdir() .. "\n")
        import("package.tools.make").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("bzip2 --help")
        assert(package:has_cfuncs("BZ2_bzCompressInit", {includes = "bzlib.h"}))
    end)
