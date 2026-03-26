package("bc_crunch")
    set_homepage("https://github.com/Geolm/bc_crunch")
    set_description("tiny dependency-free lossless compressor for BC/DXT texture streams")
    set_license("zlib")

    add_urls("https://github.com/Geolm/bc_crunch.git")

    add_versions("1.5.2", "88f0a344acc1b2ce3cc1a8393f422aa1033c0539")

    on_install("*|*64", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("bc_crunch")
                set_kind("$(kind)")
                add_files("bc_crunch.c")
                add_headerfiles("bc_crunch.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("bc_crunch", {includes = "bc_crunch.h"}))
    end)
