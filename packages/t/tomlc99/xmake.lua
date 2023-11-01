package("tomlc99")
    set_homepage("https://github.com/cktan/tomlc99")
    set_description("TOML C library")
    set_license("MIT")

    add_urls("https://github.com/cktan/tomlc99.git")
    add_versions("2023.09.30", "5221b3d3d66c25a1dc6f0372b4f824f1202fe398")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("tomlc99")
                set_kind("$(kind)")
                add_files("toml.c")
                add_headerfiles("toml.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("toml_parse", {includes = "toml.h"}))
    end)
