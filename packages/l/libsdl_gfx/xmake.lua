package("libsdl_gfx")

    set_homepage("https://www.ferzkopp.net/wordpress/2016/01/02/sdl_gfx-sdl2_gfx/")
    set_description("Simple DirectMedia Layer primitives drawing library")

    set_urls("https://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-$(version).tar.gz")
    add_versions("1.0.4", "63e0e01addedc9df2f85b93a248f06e8a04affa014a835c2ea34bfe34e576262")

    add_deps("libsdl")
    add_links("SDL2_gfx")
    add_includedirs("include", "include/SDL2")

    on_install("macosx", "linux", function (package)
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
        else
            table.insert(configs, "--enable-shared=no")
        end
        table.insert(configs, "--with-sdl-prefix=" .. package:dep("libsdl"):installdir())
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pixelColor", {includes = "SDL2/SDL2_gfxPrimitives.h"}))
    end)
