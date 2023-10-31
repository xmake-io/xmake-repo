package("recastnavigation")

    set_homepage("https://github.com/recastnavigation/recastnavigation")
    set_description("Navigation-mesh Toolset for Games")
    set_license("zlib")

    set_urls("https://github.com/recastnavigation/recastnavigation/archive/refs/tags/$(version).zip",
             "https://github.com/recastnavigation/recastnavigation.git")

    add_versions("1.5.1", "c541b56bab7543d7c741a3153af9a9024165b607de21503b90c9a399e626947a")
    add_versions("1.6.0", "6dc1667f580357e8a2154c28b7867bea7e8ad3a7")

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
