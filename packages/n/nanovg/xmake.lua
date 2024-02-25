package("nanovg")

    set_homepage("https://github.com/memononen/nanovg/")
    set_description("Antialiased 2D vector drawing library on top of OpenGL for UI and visualizations.")
    set_license("zlib")

    add_urls("https://github.com/memononen/nanovg.git")
    add_versions("2023.8.27", "f93799c078fa11ed61c078c65a53914c8782c00b")
    add_versions("2021.11.2", "e75cf72b4ad0b850a66e589d14d7b3156065dd2a")

    on_install("windows", "macosx", "linux", "mingw", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("nanovg")
                set_kind("$(kind)")
                add_files("src/*.c")
                add_headerfiles("src/(*.h)")
                if is_plat("windows", "mingw") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("nvgBeginFrame", {includes = "nanovg.h"}))
    end)
