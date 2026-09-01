package("tomlc17")
    set_homepage("https://github.com/cktan/tomlc17")
    set_description("A lightweight, strictly compliant TOML v1.1 parser for C and C++")
    set_license("MIT")

    add_urls("https://github.com/cktan/tomlc17/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cktan/tomlc17.git", {version = function (version)
        return "R" .. tostring(version):gsub("^20", ""):gsub("%.", "")
    end})
    add_versions("2026.08.21", "c4958fe2664d596ba1cc22589f56f900429fac89ad0738c3468c6e1021e92c1a")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            set_languages("c17")

            target("tomlc17")
                set_kind("$(kind)")
                add_files("src/tomlc17.c")
                add_headerfiles("src/(tomlc17.h)", "src/(tomlcpp.hpp)")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("toml_parse", {includes = "tomlc17.h"}))
    end)
