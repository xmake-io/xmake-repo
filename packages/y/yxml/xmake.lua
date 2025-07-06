package("yxml")
    set_homepage("https://dev.yorhel.nl/yxml")
    set_description("Yxml - A small, fast and correct* XML parser")
    set_license("MIT")

    add_urls("https://github.com/JulStrat/yxml.git")

    add_versions("2020.08.13", "cb1c99c7271a06687a6d945066533504b396652f")

    on_install(function (package)
        if package:is_plat("windows") and package:config("shared") then
            io.replace("yxml.h", "void yxml_init", "__declspec(dllimport) void yxml_init", {plain = true})
            io.replace("yxml.h", "yxml_ret_t yxml_parse", "__declspec(dllimport) yxml_ret_t yxml_parse", {plain = true})
            io.replace("yxml.h", "yxml_ret_t yxml_eof", "__declspec(dllimport) yxml_ret_t yxml_eof", {plain = true})
        end

        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("yxml")
                set_kind("$(kind)")
                add_files("yxml.c")
                add_headerfiles("yxml.h")
                add_includedirs(".")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("yxml_init", {includes = "yxml.h"}))
    end)
