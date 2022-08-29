package("libsdl_net")

    set_homepage("https://www.libsdl.org/projects/SDL_net/")
    set_description("Simple DirectMedia Layer networking library")

    if is_plat("windows", "mingw") then
        set_urls("https://www.libsdl.org/projects/SDL_net/release/SDL2_net-devel-$(version)-VC.zip")
        add_urls("https://github.com/libsdl-org/SDL_net/releases/download/release-$(version)/SDL2_net-devel-$(version)-VC.zip")
        add_versions("2.0.1", "c1e423f2068adc6ff1070fa3d6a7886700200538b78fd5adc36903a5311a243e")
        add_versions("2.2.0", "f364e55babb44e47b41d039a43c640aa1f76615b726855591b555321c7d870dd")
    else
        set_urls("https://www.libsdl.org/projects/SDL_net/release/SDL2_net-$(version).zip")
        add_urls("https://github.com/libsdl-org/SDL_net/releases/download/release-$(version)/SDL2_net-$(version).zip")
        add_versions("2.0.1", "52031ed9d08a5eb1eda40e9a0409248bf532dde5e8babff5780ef1925657d59f")
        add_versions("2.2.0", "1eec3a9d43df019d7916a6ecce32f2a3ad5248c82c9c237948afc712399be36d")
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::SDL2_net")
    elseif is_plat("linux") then
        add_extsources("pacman::sdl2_net", "apt::libsdl2-net-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl2_net")
    end

    add_deps("libsdl")

    add_links("SDL2_net")

    add_includedirs("include", "include/SDL2")

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
        assert(package:has_cfuncs("SDLNet_Init", {includes = "SDL2/SDL_net.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
    end)
