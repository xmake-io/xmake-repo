package("nsis")
    set_kind("binary")
    set_homepage("https://nsis.sourceforge.io/")
    set_description("NSIS (Nullsoft Scriptable Install System) is a professional open source system to create Windows installers.")

    add_urls("https://github.com/kichik/nsis.git")
    add_versions("2023.09.02", "5907dc38b6257717e6008986fd392d597da910f1")

    on_load(function (package)
        if not package:is_precompiled() then
            package:add("deps", "scons")
            package:add("deps", "zlib", {system = false})
        end
    end)

    on_install("@windows", "@msys", function (package)
        local configs = {
            "NSIS_MAX_STRLEN=8192",
            "PREFIX=" .. package:installdir(),
            "ZLIB_W32=" .. package:dep("zlib"):installdir()
            "install-compiler", "install-stubs"}
        import("package.tools.scons").build(package, configs)
    end)

    on_test(function (package)
        os.runv("makensis.exe", {"/CMDHELP"})
    end)
