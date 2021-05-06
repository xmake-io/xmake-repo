package("libsdl_gfx")

    set_homepage("https://www.ferzkopp.net/wordpress/2016/01/02/sdl_gfx-sdl2_gfx/")
    set_description("Simple DirectMedia Layer primitives drawing library")

    if is_plat("windows") then
        set_urls("https://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-$(version).zip", {alias = "ferzkopp"})
        add_urls("https://ufpr.dl.sourceforge.net/project/sdl2gfx/SDL2_gfx-$(version).tar.gz", {alias = "sourceforge"})
        add_versions("ferzkopp:1.0.4", "b6da07583b7fb8f4d8cee97cac9176b97a287f56a8112e22f38183ecf47b9dcb")
        add_versions("sourceforge:1.0.4", "63e0e01addedc9df2f85b93a248f06e8a04affa014a835c2ea34bfe34e576262")

        add_patches("1.0.4", path.join(os.scriptdir(), "patches", "1.0.4", "add-x64-support.patch"), "623ed5796c2771dc959ef0249b46a07762981a98dd25a534977f2614791d61a0")
    elseif is_plat("macosx", "linux") then
        set_urls("https://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-$(version).tar.gz")
        add_urls("https://ufpr.dl.sourceforge.net/project/sdl2gfx/SDL2_gfx-$(version).tar.gz")
        add_versions("1.0.4", "63e0e01addedc9df2f85b93a248f06e8a04affa014a835c2ea34bfe34e576262")
    end

    add_deps("libsdl")
    on_load(function(package)
        package:add("includedirs", "include")
    end)

    add_links("SDL2_gfx")

    on_install("windows", function(package)
        local file_name = "SDL2_gfx.vcxproj"
        local content = io.readfile(file_name)
        content = content:gsub("%%%(AdditionalIncludeDirectories%)", package:dep("libsdl"):installdir("include", "SDL2") .. ";%%%(AdditionalIncludeDirectories%)")
        content = content:gsub("%%%(AdditionalLibraryDirectories%)", package:dep("libsdl"):installdir("lib") .. ";%%%(AdditionalLibraryDirectories%)")
        io.writefile(file_name, content)

        local configs = {}
        local arch = package:is_arch("x86") and "Win32" or "x64"
        local mode = package:debug() and "Debug" or "Release"

        table.insert(configs, "/property:Configuration=" .. mode)
        table.insert(configs, "/property:Platform=" .. arch)
        table.insert(configs, "-target:SDL2_gfx")

        import("package.tools.msbuild").build(package, configs)

        local build_dir = path.join(arch, mode)
        os.cp(path.join(build_dir, "*.lib"), package:installdir("lib"))
        os.cp(path.join(build_dir, "*.dll"), package:installdir("bin"))
        os.cp("*.h", package:installdir("include", "SDL2"))
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
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aacircleRGBA", {includes = "SDL2/SDL2_gfxPrimitives.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
        assert(package:has_cfuncs("SDL_initFramerate", {includes = "SDL2/SDL2_framerate.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
        assert(package:has_cfuncs("rotozoomSurface", {includes = "SDL2/SDL2_rotozoom.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
        assert(package:has_cfuncs("SDL_imageFilterAdd", {includes = "SDL2/SDL2_imageFilter.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
    end)
