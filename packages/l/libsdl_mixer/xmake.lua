package("libsdl_mixer")

    set_homepage("https://www.libsdl.org/projects/SDL_mixer/")
    set_description("Simple DirectMedia Layer mixer audio library")

    if is_plat("windows", "mingw") then
        set_urls("https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-devel-$(version)-VC.zip")
        add_versions("2.0.4", "258788438b7e0c8abb386de01d1d77efe79287d9967ec92fbb3f89175120f0b0")
    else
        set_urls("https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-$(version).zip")
        add_versions("2.0.4", "9affb8c7bf6fbffda0f6906bfb99c0ea50dca9b188ba9e15be90042dc03c5ded")
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::SDL2_mixer")
    elseif is_plat("linux") then
        add_extsources("pacman::sdl2_mixer", "apt::libsdl2-mixer-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl2_mixer")
    end

    add_deps("libsdl")

    add_links("SDL2_mixer")

    on_install("windows", "mingw", function (package)
        local arch = package:arch()
        if package:is_plat("mingw") then
            arch = (arch == "x86_64") and "x64" or "x86"
        end
        os.cp("include/*", package:installdir("include/SDL2"))
        os.cp(path.join("lib", arch, "*.lib"), package:installdir("lib"))
        os.cp(path.join("lib", arch, "*.dll"), package:installdir("bin"))
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
        assert(package:has_cfuncs("Mix_Init", {includes = "SDL2/SDL_mixer.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
    end)
