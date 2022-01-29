package("bspwm")
    set_homepage("https://github.com/baskerville/bspwm")
    set_description("A tiling window manager based on binary space partitioning")

    add_urls("https://github.com/baskerville/bspwm.git")
    add_versions("2021.06.23", "e22d0fad23e0e85b401be69f2360a1c3a0767921")

    add_deps("libxcb", "xcb-util-wm")

    on_install("linux", "macosx", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            add_requires("libxcb", "xcb-util-wm")
            target("bspwm")
               set_kind("$(kind)")
               add_files("src/*.c")
               add_headerfiles("src/*.h")
               add_packages("libxcb", "xcb-util-wm")
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("get_color_pixel", {includes = "bspwm.h"}))
    end)
