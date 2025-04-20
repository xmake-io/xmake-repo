package("sfparse")
    set_homepage("https://github.com/ngtcp2/sfparse")
    set_description("Structured Field Values parser")
    set_license("MIT")

    set_urls("https://github.com/ngtcp2/sfparse.git", {submodules = false})

    add_versions("2024.12.15", "930bdf8421f29cf0109f0f1baaafffa376973ed5")
    add_versions("2024.05.12", "c669673012f9d535ec3bcf679fe911c8c75a479f")

    add_includedirs("include", "include/sfparse")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("sfparse")
                set_kind("$(kind)")
                add_files("sfparse.c")
                add_headerfiles("sfparse.h", {prefixdir = "sfparse"})
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        if package:gitref() or package:version():ge("2024.12.15") then
            assert(package:has_cfuncs("sfparse_parser_init", {includes = "sfparse.h"}))
        else
            assert(package:has_cfuncs("sf_parser_param", {includes = "sfparse.h"}))
        end
    end)
