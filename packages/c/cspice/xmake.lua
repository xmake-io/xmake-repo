package("cspice")
    set_homepage("https://naif.jpl.nasa.gov/naif/toolkit.html")
    set_description("An Observation Geometry System for Space Science Missions")

    if is_plat("linux") then
        set_urls("https://naif.jpl.nasa.gov/pub/naif/toolkit//C/PC_Linux_GCC_64bit/packages/cspice.tar.Z")
        add_versions("v67", "60a95b51a6472f1afe7e40d77ebdee43c12bb5b8823676ccc74692ddfede06ce")
    elseif is_plat("macosx") then
        set_urls("https://naif.jpl.nasa.gov/pub/naif/toolkit//C/MacM1_OSX_clang_64bit/packages/cspice.tar.Z")
        add_versions("v67", "0deae048443e11ca4d093cac651d9785d4f2594631a183d85a3d58949f4d0aa9")
    end

    on_install("linux", "macosx", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("cspice")
                set_kind("$(kind)")
                add_headerfiles("include/*.h")
                add_files("src/cspice/*.c")
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("j2000_c", {includes = {"SpiceUsr.h"}}))
    end)
