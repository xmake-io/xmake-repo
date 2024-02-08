package("genie")

    set_kind("binary")
    set_homepage("https://github.com/bkaradzic/GENie")
    set_description("GENie - Project generator tool")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/bkaradzic/GENie.git")
    add_versions("1160", "f9bd455a8439dbcb807816c0be9e4aedf5991bc3")
    add_versions("1165", "5461c5ab94d0365c40031fef8f459b9c21b4d37a")
    add_versions("1170", "22cc907a4351db46c55f73e6aa901f1b2f0c52ad")

    on_install("@windows", "@msys", "@macosx", "@linux", function (package)
        os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {mode = "release"})
    end)

    on_test(function (package)
        local outfile = os.tmpfile()
        os.execv("genie" .. (package:is_plat("windows") and ".exe" or ""), {"--version"}, {stdout = outfile, try = true})
        local outdata = io.readfile(outfile)
        assert(outdata:find("GENie - Project generator tool", 1, true))
    end)
