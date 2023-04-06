package("convertutf")
    set_homepage("https://home.unicode.org/")
    set_description("Conversions between UTF-32, UTF-16, and UTF-8. Circa 2004.")

    set_urls("https://github.com/xmake-mirror/convertutf/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-mirror/convertutf.git")
    add_versions("v1.0.1", "ecd79378cc9f24034a2edebf5f198e84c9eb8046261f8208908d2b29d4fa4d99")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            target("convertutf")
                set_kind("$(kind)")
                set_languages("c99")
                add_files("ConvertUTF.c")
                add_headerfiles("ConvertUTF.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        local configs = {}
        configs.kind = package:config("shared") and "shared" or "static"
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ConvertUTF8toUTF16", {includes = "ConvertUTF.h"}))
    end)
