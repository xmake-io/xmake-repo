package("nsis")
    set_kind("binary")
    set_homepage("https://nsis.sourceforge.io/")
    set_description("NSIS (Nullsoft Scriptable Install System) is a professional open source system to create Windows installers.")

    add_urls("https://github.com/kichik/nsis/archive/refs/tags/$(version).tar.gz", {version = function (version)
        return version:gsub("%.", "")
    end})
    add_urls("https://github.com/kichik/nsis.git")

    add_versions("v3.09", "4d2ce0d2fecc28bd2d8a0108152339f091e9d1f35342dac0eb4594157435292b")

    add_resources("3.x", "uac", "https://nsis.sourceforge.io/mediawiki/images/8/8f/UAC.zip", "20e3192af5598568887c16d88de59a52c2ce4a26e42c5fb8bee8105dcbbd1760")

    on_load(function (package)
        if not package:is_precompiled() then
            package:add("deps", "scons")
            package:add("deps", "zlib", {system = false, host = true, configs = {shared = true}})
        end
    end)

    on_install("@windows|x64", "@windows|x86", function (package)
        local zlib_installdir = package:dep("zlib"):installdir()
        os.cp(path.join(zlib_installdir, "lib", "zlib.lib"), path.join(package:installdir("lib"), "zdll.lib"))
        os.cp(path.join(zlib_installdir, "bin", "zlib.dll"), path.join(package:installdir("bin"), "zlib.dll"))
        os.cp(path.join(zlib_installdir, "include", "*.h"), package:installdir("include"))
        local arch = package:arch()
        if arch == "x64" then
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
