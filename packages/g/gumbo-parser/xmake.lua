package("gumbo-parser")
    set_homepage("https://github.com/google/gumbo-parser")
    set_description("An HTML5 parsing library in pure C99")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/gumbo-parser/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/gumbo-parser.git")
    add_versions("v0.10.1", "28463053d44a5dfbc4b77bcf49c8cee119338ffa636cc17fc3378421d714efad")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("gumbo")
                set_kind("$(kind)")
                add_files("src/*.c")
                add_headerfiles("src/*.h")
                if is_plat("windows") then
                    add_includedirs("visualc/include")
                    if is_kind("shared") then
                        add_rules("utils.symbols.export_all", {export_classes = true})
                    end
                end
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gumbo_parse_with_options", {includes = "gumbo.h"}))
    end)
