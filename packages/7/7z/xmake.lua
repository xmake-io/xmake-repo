package("7z")

    set_kind("binary")
    set_homepage("https://www.7-zip.org/")
    set_description("A file archiver with a high compression ratio.")

    set_urls("https://github.com/SirLynix/7z/archive/refs/tags/$(version).tar.gz",
             "https://github.com/SirLynix/7z.git")
    add_versions("21.02", "39c20421b199c7fe19b7a5328c4808f096a12ecfa02cf65c69317cc8f6e4bdf8")
    add_patches("21.02", path.join(os.scriptdir(), "patches", "21.02", "backport-21.03-fix-for-GCC-10.patch"), "f1d8fa0bbb25123b28e9b2842da07604238b77e51b918260a369f97c2f694c89")

    on_install("macosx", "linux", function (package)
        os.cd("CPP/7zip/Bundles/Alone2")
        os.vrun("make -j -f ../../cmpl_gcc.mak")

        local bin = package:installdir("bin")
        os.cp("b/g/7zz", bin)
        os.ln(bin .. "/7zz", bin .. "/7z")
    end)

    on_install("windows", function (package)
        local archdir = package:is_arch("x64", "x86_64") and "x64" or "x86"
        os.cd("CPP/7zip/Bundles/Alone2")
        local configs = {"-f", "makefile"}
        table.insert(configs, "PLATFORM=" .. archdir)
        import("package.tools.nmake").build(package, configs)

        local bin = package:installdir("bin")
        os.cp(archdir .. "/7zz.exe", bin .. "/7z.exe")
    end)

    on_test(function (package)
        os.vrun("7z --help")
    end)
