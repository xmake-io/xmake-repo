package("giflib")
    set_homepage("https://sourceforge.net/projects/giflib/")
    set_description("A library for reading and writing gif images.")
    set_license("MIT")

    add_urls("https://github.com/xmake-mirror/giflib/releases/download/$(version)/giflib-$(version).tar.gz",
             "https://downloads.sourceforge.net/project/giflib/giflib-$(version).tar.gz")

    add_versions("5.2.2", "be7ffbd057cadebe2aa144542fd90c6838c6a083b5e8a9048b8ee3b66b29d5fb")
    add_versions("5.2.1", "31da5562f44c5f15d63340a09a4fd62b48c45620cd302f77a6d9acf0077879bd")

    add_patches("5.2.1", "patches/5.2.1/unistd.h.patch", "0f1f7b9a295c9965529608f7e9d810b7f7a2642b3b18910402d5d7ce8b86fc13")

    add_configs("utils", {description = "Build utility binaries.", default = true, type = "boolean"})

    on_load(function (package)
        if package:config("utils") and package:is_plat("windows") then
            package:add("deps", "cgetopt")
        end
    end)

    on_install(function (package)
        local utils = package:config("utils")
        if utils and package:is_plat("windows") then
            -- fix unresolved external symbol snprintf before vs2013
            for _, file in ipairs({"gif2rgb.c", "gifbuild.c", "gifclrmp.c", "giffix.c", "giftext.c", "giftool.c"}) do
                io.replace(file, "snprintf", "_snprintf", {plain = true})
            end
        end

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {utils = utils})
        if utils then
            package:addenv("PATH", "bin")
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("GifMakeMapObject", {includes = "gif_lib.h"}))
    end)
