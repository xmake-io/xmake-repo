package("libsdl_gfx")
    add_deps("libsdl")

    set_homepage("https://www.ferzkopp.net/wordpress/2016/01/02/sdl_gfx-sdl2_gfx/")
    set_description("Simple DirectMedia Layer primitives drawing library")

    if is_plat("macosx", "linux") then
        set_urls("https://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-$(version).tar.gz")
        add_versions("1.0.4", "63e0e01addedc9df2f85b93a248f06e8a04affa014a835c2ea34bfe34e576262")
    end

    add_links("SDL2_gfx")

    on_install("macosx", "linux", function (package)
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
        else
            table.insert(configs, "--enable-shared=no")
        end

        table.insert(configs, "--with-sdl-prefix=" .. package:dep("libsdl"):installdir())

        import("package.tools.autoconf").install(package, configs)
        local file_name = path.join(package:installdir("include"), "SDL2", "SDL2_framerate.h")
        local content = io.readfile(file_name)

        content = content:gsub("\"SDL.h\"", "<SDL2/SDL.h>")

        io.writefile(file_name, content)

        local file_name = path.join(package:installdir("include"), "SDL2", "SDL2_gfxPrimitives.h")
        local content = io.readfile(file_name)

        content = content:gsub("\"SDL.h\"", "<SDL2/SDL.h>")

        io.writefile(file_name, content)

        local file_name = path.join(package:installdir("include"), "SDL2", "SDL2_rotozoom.h")
        local content = io.readfile(file_name)

        content = content:gsub("\"SDL.h\"", "<SDL2/SDL.h>")

        io.writefile(file_name, content)
    end)