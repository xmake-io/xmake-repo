package("libsdl_gfx")
    add_deps("libsdl")
    on_load(function(package)
        package:add("includedirs", "include")
    end)

    set_homepage("https://www.ferzkopp.net/wordpress/2016/01/02/sdl_gfx-sdl2_gfx/")
    set_description("Simple DirectMedia Layer primitives drawing library")

    if is_plat("windows") then
        set_urls("https://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-$(version).zip")
        add_versions("1.0.4", "b6da07583b7fb8f4d8cee97cac9176b97a287f56a8112e22f38183ecf47b9dcb")
    elseif is_plat("macosx", "linux") then
        set_urls("https://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-$(version).tar.gz")
        add_versions("1.0.4", "63e0e01addedc9df2f85b93a248f06e8a04affa014a835c2ea34bfe34e576262")
    end

    add_links("SDL2_gfx")

    on_install("windows", function(package)
        local file_name = "SDL2_gfx.vcxproj"
        local content = io.readfile(file_name)

        content = content:gsub("<WindowsTargetPlatformVersion>10.0.14393.0</WindowsTargetPlatformVersion>", "")
        content = content:gsub("v141", "v142")
        content = content:gsub("%%%(AdditionalIncludeDirectories%)", package:dep("libsdl"):installdir("include", "SDL2") .. ";%%%(AdditionalIncludeDirectories%)")
        content = content:gsub("%%%(AdditionalLibraryDirectories%)", package:dep("libsdl"):installdir("lib") .. ";%%%(AdditionalLibraryDirectories%)")

        io.writefile(file_name, content)

        local configs = {}
        local build_dir = ""

        if package:arch() == "x86" then
            build_dir = "Win32"
        else
            build_dir = "x64"
        end

        table.insert(configs, "/property:Configuration=Release")
        table.insert(configs, "/property:Platform=" .. build_dir)
        table.insert(configs, "-target:SDL2_gfx")

        import("package.tools.msbuild").build(package, configs)

        build_dir = path.join(build_dir, "Release")

        os.cp(path.join(build_dir, "*.lib"), package:installdir("lib"))
        os.cp(path.join(build_dir, "*.dll"), package:installdir("lib"))
        os.cp("*.h", package:installdir("include", "SDL2"))

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