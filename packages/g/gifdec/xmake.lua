package("gifdec")
    set_homepage("https://github.com/lecram/gifdec")
    set_description("small C GIF decoder")

    add_urls("https://github.com/lecram/gifdec.git")
    add_versions("2021.12.04", "1dcbae19363597314f6623010cc80abad4e47f7c")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("gifdec")
                set_kind("$(kind)")
                add_files("gifdec.c")
                add_headerfiles("gifdec.h)")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gd_open_gif", {includes = "gifdec.h"}))
    end)
