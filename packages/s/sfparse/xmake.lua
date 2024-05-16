package("sfparse")

    set_homepage("https://github.com/ngtcp2/sfparse")
    set_description("Structured Field Values parser")
    set_license("MIT")

    set_urls("https://github.com/ngtcp2/sfparse.git")
    add_versions("2024.05.12", "c669673012f9d535ec3bcf679fe911c8c75a479f")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("sfparse")
                set_kind("$(kind)")
                add_files("sfparse.c")
                add_headerfiles("sfparse.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sf_parser_param", {includes = "sfparse.h"}))
    end)
