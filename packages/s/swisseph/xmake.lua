package("swisseph")
    set_homepage("https://www.astro.com/swisseph/swephinfo_e.htm")
    set_description("Swiss Ephemeris source code, official release by Astrodienst.")
    set_license("AGPL-3.0")

    add_urls("https://github.com/aloistr/swisseph/archive/refs/tags/$(version).tar.gz",
             "https://github.com/aloistr/swisseph.git")

    add_versions("v2.10.03", "8c166796767a560691581575b6eb4b4383d849e542b16647dca2e0b127fb70b0")

    if is_plat("linux", "bsd") then
        add_syslinks("m", "dl")
    end

    on_load("windows", function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "USE_DLL")
        end
    end)

    on_install(function (package)
        if package:is_plat("android") and package:is_arch("armeabi-v7a") then
            local ndk_sdkver = package:toolchain("ndk"):config("ndk_sdkver")
            if ndk_sdkver and tonumber(ndk_sdkver) < 24 then
                io.replace("swejpl.c", "ftello", "ftell", {plain = true})
                io.replace("swejpl.c", "fseeko", "fseek", {plain = true})
            end
        end

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
            if is_plat("linux", "bsd") then
                add_syslinks("m", "dl")
            end
            if is_plat("windows") and is_kind("shared") then
                add_defines("MAKE_DLL")
            end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("swe_version", {includes = {"swisseph/swephexp.h", "swisseph/sweph.h"}}))
    end)
