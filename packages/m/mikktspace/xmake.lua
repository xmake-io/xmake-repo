package("mikktspace")

    set_homepage("http://www.mikktspace.com/")
    set_description("A common standard for tangent space used in baking tools to produce normal maps.")

    add_urls("https://github.com/mmikk/MikkTSpace.git")
    add_versions("2020.03.26", "3e895b49d05ea07e4c2133156cfa94369e19e409")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("mikktspace")
                set_kind("$(kind)")
                add_files("mikktspace.c")
                add_headerfiles("mikktspace.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("genTangSpace", {includes = "mikktspace.h"}))
    end)
