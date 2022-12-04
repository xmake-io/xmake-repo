package("libsdl_gfx")

    set_homepage("https://www.ferzkopp.net/wordpress/2016/01/02/sdl_gfx-sdl2_gfx/")
    set_description("Simple DirectMedia Layer primitives drawing library")

    if is_plat("windows") then
        set_urls("https://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-$(version).zip", {alias = "ferzkopp"})
        add_urls("https://sourceforge.net/projects/sdl2gfx/files/SDL2_gfx-$(version).tar.gz", {alias = "sourceforge"})
        add_versions("ferzkopp:1.0.4", "b6da07583b7fb8f4d8cee97cac9176b97a287f56a8112e22f38183ecf47b9dcb")
        add_versions("sourceforge:1.0.4", "63e0e01addedc9df2f85b93a248f06e8a04affa014a835c2ea34bfe34e576262")

        add_patches("1.0.4", path.join(os.scriptdir(), "patches", "1.0.4", "add-x64-support.patch"), "2ea0eda111d95864bbc9aedbf8aa91dd3923208d2816a626dfd6bc173986e426")
        add_patches("1.0.4", path.join(os.scriptdir(), "patches", "1.0.4", "lrint_fix.patch"), "9fb928306fb25293720214377bff2f605f60ea26f43ea5346cf1268c504aff1a")
    elseif is_plat("macosx", "linux") then
        set_urls("https://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-$(version).tar.gz")
        add_urls("https://sourceforge.net/projects/sdl2gfx/files/SDL2_gfx-$(version).tar.gz")
        add_versions("1.0.4", "63e0e01addedc9df2f85b93a248f06e8a04affa014a835c2ea34bfe34e576262")
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::SDL2_gfx")
    elseif is_plat("linux") then
        add_extsources("pacman::sdl2_gfx", "apt::libsdl2-gfx-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl2_gfx")
    end

    add_deps("libsdl")

    add_links("SDL2_gfx")

    add_includedirs("include", "include/SDL2")

    on_install("windows", function(package)
        import("core.tool.toolchain")
        local vs = tonumber(toolchain.load("msvc"):config("vs"))
        if vs < 2019 then
            raise("Your compiler is too old to use this library.")
        end

        local file_name = "SDL2_gfx.vcxproj"
        local content = io.readfile(file_name)
        content = content:gsub("%%%(AdditionalIncludeDirectories%)", package:dep("libsdl"):installdir("include", "SDL2") .. ";%%(AdditionalIncludeDirectories)")
        content = content:gsub("%%%(AdditionalLibraryDirectories%)", package:dep("libsdl"):installdir("lib") .. ";%%(AdditionalLibraryDirectories)")
        io.writefile(file_name, content)

        -- MSVC trick no longer required since C++11
        io.replace("SDL2_gfxPrimitives.c", "#if defined(_MSC_VER)", "#if 0", {plain = true})

        local configs = {}
        local arch = package:is_arch("x86") and "Win32" or "x64"
        local mode = package:debug() and "Debug" or "Release"

        table.insert(configs, "/property:Configuration=" .. mode)
        table.insert(configs, "/property:Platform=" .. arch)
        if vs >= 2022 then
            table.insert(configs, "/p:PlatformToolset=v143")
        end
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
        if package:is_plat("linux") and package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        local libsdl = package:dep("libsdl")
        if libsdl and not libsdl:is_system() then
            table.insert(configs, "--with-sdl-prefix=" .. libsdl:installdir())
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aacircleRGBA", {includes = "SDL2/SDL2_gfxPrimitives.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
        assert(package:has_cfuncs("SDL_initFramerate", {includes = "SDL2/SDL2_framerate.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
        assert(package:has_cfuncs("rotozoomSurface", {includes = "SDL2/SDL2_rotozoom.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
        assert(package:has_cfuncs("SDL_imageFilterAdd", {includes = "SDL2/SDL2_imageFilter.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
    end)
