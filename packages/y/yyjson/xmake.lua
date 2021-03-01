package("yyjson")

    set_homepage("https://github.com/ibireme/yyjson")
    set_description("The fastest JSON library in C.")

    add_urls("https://github.com/ibireme/yyjson/archive/$(version).tar.gz",
             "https://github.com/ibireme/yyjson.git")
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
