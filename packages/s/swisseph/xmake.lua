package("swisseph")
    set_kind("library")
    set_homepage("https://www.astro.com/swisseph/")
    set_description("The SWISS EPHEMERIS is the high precision ephemeris developed by Astrodienst")

    add_versions("v2.10.03", "4e32fd543e8d9cd99eb58dbd67128feb1c52ab160ca8223a4045d4a2f814f8a4")
    set_urls("https://github.com/aloistr/swisseph/archive/refs/tags/$(version).zip")

    on_install("linux", "macosx", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")

        local configs = {buildir = "xbuild", vers = package:version_str()}

        if package:config("shared") then
            configs.kind = "shared"
        end

        import("package.tools.xmake").install(package, configs)
    end)

    on_test("linux", "macosx", function (package)
        assert(package:has_cfuncs("swe_version", {includes = {"swephexp.h", "sweph.h"}}))
    end)
