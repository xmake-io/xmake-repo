package("mpdecimal")

    set_homepage("https://www.bytereef.org/mpdecimal/index.html")
    set_description("mpdecimal is a package for correctly-rounded arbitrary precision decimal floating point arithmetic.")
    set_license("BSD-2-Clause")

    add_urls("https://www.bytereef.org/software/mpdecimal/releases/mpdecimal-$(version).tar.gz")
    add_versions("2.5.1", "9f9cd4c041f99b5c49ffb7b59d9f12d95b683d88585608aa56a6307667b2b21f")

    on_install("windows", function (package)
        for _, header in ipairs({"libmpdec/mpdecimal32vc.h", "libmpdec/mpdecimal64vc.h", "libmpdec++/decimal.hh"}) do
            io.replace(header, "if defined(_DLL)", "if defined(MPDEC_DLL)", {plain = true})
        end
        local configs = {}
        table.insert(configs, "DEBUG=" .. (package:debug() and "1" or "0"))
        table.insert(configs, "MACHINE=" .. (package:is_arch("x64") and "x64" or "ppro"))
        for _, library in ipairs({"libmpdec", "libmpdec++"}) do
            local oldir = os.cd(library)
            os.mv("Makefile.vc", "Makefile")
            io.replace("Makefile", "/MD", "/MD /DMPDEC_DLL", {plain = true})
            if (package:config("runtimes") and package:has_runtime("MT", "MTd")) or (package:config("vs_config") and package:config("vs_config"):startswith("MT")) then
                io.replace("Makefile", "/MD", "/MT", {plain = true})
            else
                io.replace("Makefile", "/MT", "/MD", {plain = true})
            end
            import("package.tools.nmake").build(package, configs)
            if package:config("shared") then
                os.cp("*.dll", package:installdir("bin"))
                os.cp("*.dll.lib", package:installdir("lib"))
            else
                os.cp("*.lib|*.dll.lib", package:installdir("lib"))
            end
            os.cd(oldir)
        end
        io.replace("libmpdec/mpdecimal.h", "defined(MPDEC_DLL)", (package:config("shared") and "1" or "0"), {plain = true})
        os.cp("libmpdec/mpdecimal.h", package:installdir("include"))
        io.replace("libmpdec++/decimal.hh", "defined(MPDEC_DLL)", (package:config("shared") and "1" or "0"), {plain = true})
        os.cp("libmpdec++/decimal.hh", package:installdir("include"))
    end)

    on_install("macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        import("package.tools.autoconf").install(package, configs)
        if package:config("shared") then
            os.rm(path.join(package:installdir("lib"), "*.a"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mpd_version", {includes = "mpdecimal.h"}))
    end)
