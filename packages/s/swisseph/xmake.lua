package("swisseph")
    set_homepage("https://www.astro.com/swisseph/")
    set_description("The SWISS EPHEMERIS is the high precision ephemeris developed by Astrodienst")

    set_urls("https://github.com/aloistr/swisseph/archive/refs/tags/$(version).zip")
    add_versions("v2.10.03", "4e32fd543e8d9cd99eb58dbd67128feb1c52ab160ca8223a4045d4a2f814f8a4")

    on_install("linux", "macosx", function (package)
        io.writefile("xmake.lua", [[
        add_rules("mode.debug", "mode.release")
        target("swisseph")
            set_kind("$(kind)")
            add_files(
                "swedate.c",
                "swehouse.c",
                "swejpl.c",
                "swemmoon.c",
                "swemplan.c",
                "sweph.c",
                "swephlib.c",
                "swecl.c",
                "swehel.c"
            )
            add_headerfiles("*.h", {prefixdir = "swisseph"})
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test("linux", "macosx", function (package)
        assert(package:has_cfuncs("swe_version", {includes = {"swisseph/swephexp.h", "swisseph/sweph.h"}}))
    end)
