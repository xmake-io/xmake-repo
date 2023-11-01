package("recastnavigation")

    set_homepage("https://github.com/recastnavigation/recastnavigation")
    set_description("Navigation-mesh Toolset for Games")
    set_license("zlib")

    set_urls("https://github.com/recastnavigation/recastnavigation/archive/refs/tags/$(version).tar.gz",
             "https://github.com/recastnavigation/recastnavigation.git")

    add_versions("1.5.1", "fdd0d9ac656993cb34d02d3c6c41e3a3311c1da79b84bbedca71c5d629f915fc")
    add_versions("v1.6.0", "d48ca0121962fa0639502c0f56c4e3ae72f98e55d88727225444f500775c0074")

    on_install(function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("rcCreateHeightfield", {includes = "Recast.h"}))
    end)
