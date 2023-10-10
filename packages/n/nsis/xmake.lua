package("nsis")
    set_kind("binary")
    set_homepage("https://nsis.sourceforge.io/")
    set_description("NSIS (Nullsoft Scriptable Install System) is a professional open source system to create Windows installers.")

    add_urls("https://github.com/kichik/nsis/archive/refs/tags/$(version).tar.gz", {version = function (version)
        return version:gsub("%.", "")
    end})
    add_urls("https://github.com/kichik/nsis.git")

    add_versions("v3.09", "4d2ce0d2fecc28bd2d8a0108152339f091e9d1f35342dac0eb4594157435292b")

    on_load(function (package)
        if not package:is_precompiled() then
            package:add("deps", "scons")
            package:add("resources", "3.x", "uac", "https://nsis.sourceforge.io/mediawiki/images/8/8f/UAC.zip", "20e3192af5598568887c16d88de59a52c2ce4a26e42c5fb8bee8105dcbbd1760")
            package:add("resources", "3.x", "zlib", "https://downloads.sourceforge.net/project/libpng/zlib/1.2.8/zlib128-dll.zip", "a03fd15af45e91964fb980a30422073bc3f3f58683e9fdafadad3f7db10762b1")
        end
    end)

    on_install("@windows|x64", "@windows|x86", "@macosx", "@linux", function (package)
        local zlib = package:resourcedir("zlib")
        os.cp(path.join(zlib, "include"), package:installdir())
        os.cp(path.join(zlib, "lib"), package:installdir())
        os.cp(path.join(zlib, "zlib1.dll"), package:installdir())
        os.cp(path.join(zlib, "zlib1.dll"), package:installdir("bin"))
        local arch = package:arch()
        if arch == "x64" or arch == "x86_64" then
            arch = "amd64"
        end
        local configs = {
            "NSIS_MAX_STRLEN=8192",
            "TARGET_ARCH=" .. arch,
            "PREFIX=" .. package:installdir(),
            "ZLIB_W32=" .. package:installdir(),
            "install-compiler", "install-stubs"}
        import("package.tools.scons").build(package, configs)
        os.cp(path.join(package:resourcedir("uac"), "UAC.nsh"), path.join(package:installdir(), "Include"))
    end)

    on_test(function (package)
        os.runv("makensis", {"/CMDHELP"})
    end)

