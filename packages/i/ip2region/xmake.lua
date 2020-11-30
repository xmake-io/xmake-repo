package("ip2region")

    set_homepage("https://github.com/lionsoul2014/ip2region")
    set_description("IP address region search library.")
    set_license("Apache-2.0")

    set_urls("https://github.com/lionsoul2014/ip2region/archive/$(version)-release.tar.gz",
            {version = function (version) return version:gsub('%.', '-') end})

    add_versions("v2020.10.31", "83d9bfef8e8e3a5107f605a17fe36b22078b3993b0928f88e2163f17d74eb759")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("ip2region")
                set_kind("$(kind)")
                add_includedirs("binding/c")
                add_files("binding/c/ip2region.c")
                add_headerfiles("binding/c/ip2region.h")
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ip2region_create", {includes = "ip2region.h"}))
    end)