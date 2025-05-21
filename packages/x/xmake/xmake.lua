package("xmake")
    set_homepage("https://github.com/xmake-io/xmake")
    set_description("xmake - A cross-platform build utility based on Lua")

    set_urls("https://github.com/xmake-io/xmake/releases/download/$(version)/xmake-$(version).tar.gz",
             "https://github.com/xmake-io/xmake.git")
    add_versions("v2.9.9", "e92505b83bc9776286eae719d58bcea7ff2577afe12cb5ccb279c81e7dbc702d")

    add_patches("v2.9.9", path.join(os.scriptdir(), "patches", "v2.9.9", "0001-use-.-.-to-replace-projectdir.patch"), "045625eda45887bc0cb703cfaf6679f72d7f3797c637fc17861d3e0d3b7b23d6")

    on_install(function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        if not package:is_cross() then
            for _, tool in ipairs({"xmake"}) do
                if package:config(tool) then
                    os.vrunv(tool, {"--version"})
                end
            end
        end
    end)
