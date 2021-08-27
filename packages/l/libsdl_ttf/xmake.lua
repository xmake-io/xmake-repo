package("libsdl_ttf")

    set_homepage("https://www.libsdl.org/projects/SDL_ttf/")
    set_description("Simple DirectMedia Layer text rendering library")

    if is_plat("windows", "mingw") then
        set_urls("https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-devel-$(version)-VC.zip")
        add_versions("2.0.15", "aab0d81f1aa6fe654be412efc85829f2b188165dca6c90eb4b12b673f93e054b")
    else
        set_urls("https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-$(version).zip")
        add_versions("2.0.15", "cdb72b5b1c3b27795fa128af36f369fee5d3e38a96c350855da0b81880555dbc")
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::SDL2_ttf")
    elseif is_plat("linux") then
        add_extsources("pacman::sdl2_ttf", "apt::libsdl2-ttf-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl2_ttf")
    end

    add_deps("libsdl")
    if is_plat("linux", "macosx") then
        add_deps("freetype")
    end

    add_links("SDL2_ttf")

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
        assert(package:has_cfuncs("TTF_Init", {includes = "SDL2/SDL_ttf.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
    end)
