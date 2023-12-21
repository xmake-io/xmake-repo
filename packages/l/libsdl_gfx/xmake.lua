package("libsdl_gfx")

    set_homepage("https://www.ferzkopp.net/wordpress/2016/01/02/sdl_gfx-sdl2_gfx/")
    set_description("Simple DirectMedia Layer primitives drawing library")

    if is_plat("windows") then
        set_urls("https://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-$(version).zip", {alias = "ferzkopp"})
        add_urls("https://sourceforge.net/projects/sdl2gfx/files/SDL2_gfx-$(version).tar.gz", {alias = "sourceforge"})
        add_versions("ferzkopp:1.0.4", "b6da07583b7fb8f4d8cee97cac9176b97a287f56a8112e22f38183ecf47b9dcb")
        add_versions("sourceforge:1.0.4", "63e0e01addedc9df2f85b93a248f06e8a04affa014a835c2ea34bfe34e576262")

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

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_includedirs("include", "include/SDL2")

    on_load(function (package)
        if package:config("shared") then
            package:add("deps", "libsdl", { configs = { shared = true }})
        else
            package:add("deps", "libsdl")
        end
    end)

    on_install("windows|x86", "windows|x64", "macosx", "linux", function(package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            if is_kind("shared") then
                add_requires("libsdl", {configs = {shared = true}})
            else
                add_requires("libsdl")
            end
            target("SDL2_gfx")
                set_kind("$(kind)")
                add_files("*.c")
                add_headerfiles("*.h", {prefixdir = "SDL2"})
                add_packages("libsdl")
                add_rules("utils.install.pkgconfig_importfiles")
                if is_plat("windows") and is_kind("shared") then
                    add_defines("DLL_EXPORT")
                end
                if is_arch("x86", "i386") then
                    add_defines("USE_MMX")
                end
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)

    end)

    on_test(function (package)
        assert(package:has_cfuncs("aacircleRGBA", {includes = "SDL2/SDL2_gfxPrimitives.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
        assert(package:has_cfuncs("SDL_initFramerate", {includes = "SDL2/SDL2_framerate.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
        assert(package:has_cfuncs("rotozoomSurface", {includes = "SDL2/SDL2_rotozoom.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
        assert(package:has_cfuncs("SDL_imageFilterAdd", {includes = "SDL2/SDL2_imageFilter.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
    end)
