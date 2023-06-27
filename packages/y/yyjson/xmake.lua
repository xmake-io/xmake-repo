package("yyjson")

    set_homepage("https://github.com/ibireme/yyjson")
    set_description("The fastest JSON library in C.")

    add_urls("https://github.com/ibireme/yyjson/archive/$(version).tar.gz",
             "https://github.com/ibireme/yyjson.git")
    add_versions("0.5.1", "b484d40b4e20cc3174a6fdc160d0f20f961417f9cb3f6dc1cf6555fffa8359f3")
    add_versions("0.5.0", "1a65c41d25394c979ad26554a0befb8006ecbf9f7f3a5b0130fdae4f2dd03d42")
    add_versions("0.4.0", "061fe713391d7f3f85f13e8bb2752a4cdeb8e70ce20d68e1e9e4332bd0bf64fa")
    add_versions("0.3.0", "f5ad3e3be40f0307a732c2b8aff9a1ba6014a6b346f3ec0b128459607748e990")    
    add_versions("0.2.0", "43aacdc6bc3876dc1322200c74031b56d8d7838c04e46ca8a8e52e37ea6128da")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("yyjson")
                set_kind("$(kind)")
                add_files("src/*.c")
                add_headerfiles("src/*.h")
                if is_kind("shared") and is_plat("windows") then
                    add_defines("YYJSON_EXPORTS")
                end
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("yyjson_read", {includes = "yyjson.h"}))
    end)
