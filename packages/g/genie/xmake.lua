package("genie")
    set_kind("binary")
    set_homepage("https://github.com/bkaradzic/GENie")
    set_description("GENie - Project generator tool")

    if is_plat("windows") then
        add_urls("https://raw.githubusercontent.com/bkaradzic/bx/aa5090bbd8c39e84d483f4850a7d9ca7ff9241ed/tools/bin/windows/genie.exe")
        add_versions("1160.0", "a1226a0098f6ff4895a423df17737af90cc0af9effce7cc81fe904c9b2e02e8f")
    else
        add_urls("https://github.com/bkaradzic/GENie.git")
        add_versions("1160.0", "0f5133b66d103efbcdf7c0d23f6cb6b353282e38")
    end

    on_install("@windows", function (package)
        os.cp("*", package:installdir("bin"))
    end)

    on_install("@macosx", "@linux", function (package)
        import("package.tools.make").build(package, configs)
        os.cp("bin/*/genie", package:installdir("bin"))
    end)

    on_test(function (package)
        local outfile = os.tmpfile()
        os.execv("genie" .. (package:is_plat("windows") and ".exe" or ""), {"--version"}, {stdout = outfile, try = true})
        local outdata = io.readfile(outfile)
        assert(outdata:find("GENie - Project generator tool", 1, true))
    end)
