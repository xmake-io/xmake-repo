package("libsdl_mixer")

    set_homepage("https://www.libsdl.org/projects/SDL_mixer/")
    set_description("Simple DirectMedia Layer mixer audio library")

    if is_plat("windows", "mingw") then
        set_urls("https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-devel-$(version)-VC.zip")
        add_urls("https://github.com/libsdl-org/SDL_mixer/releases/download/release-$(version)/SDL2_mixer-devel-$(version)-VC.zip")
        add_versions("2.0.4", "258788438b7e0c8abb386de01d1d77efe79287d9967ec92fbb3f89175120f0b0")
        add_versions("2.6.0", "b8862b95340b8990177fdb3fb1f22fe5fd089d8b2ad0a30bf7d84e0f4a6138ae")
        add_versions("2.6.1", "e086e1fed423a801e0e7573af063f2f51d3bcef0c9da356ed8a62a7a7f7a0815")
        add_versions("2.6.2", "7f050663ccc7911bb9c57b11e32ca79578b712490186b8645ddbbe4e7d2fe1c9")
    else
        set_urls("https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-$(version).zip")
        add_urls("https://github.com/libsdl-org/SDL_mixer/releases/download/release-$(version)/SDL2_mixer-$(version).zip")
        add_versions("2.0.4", "9affb8c7bf6fbffda0f6906bfb99c0ea50dca9b188ba9e15be90042dc03c5ded")
        add_versions("2.6.0", "aca0ffc96a4bf2a56a16536a269de28e341ce38a46a25180bc1ef75e19b08a3a")
        add_versions("2.6.1", "788c748c1d3a87126511e60995b03526ed4e31e2ba053dffd9dcc8abde97b950")
        add_versions("2.6.2", "61549615a67e731805ca1df553e005be966a625c1d20fb085bf99edeef6e0469")
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

    add_includedirs("include", "include/SDL2")

    on_load(function (package)
        if package:version():ge("2.6") and package:is_plat("macosx", "linux") then
            package:add("deps", "cmake")
        end
    end)

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
        if package:version():ge("2.6") then
            local configs = {"-DSDL2MIXER_SAMPLES=OFF",
                             "-DSDL2MIXER_FLAC=OFF",
                             "-DSDL2MIXER_OPUS=OFF",
                             "-DSDL2MIXER_MOD=OFF",
                             "-DSDL2MIXER_MIDI=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            if libsdl and not libsdl:is_system() then
                table.insert(configs, "-DSDL2_DIR=" .. libsdl:installdir())
            end
            import("package.tools.cmake").install(package, configs)
        else
            local configs = {}
            table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
            table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
            local libsdl = package:dep("libsdl")
            if libsdl and not libsdl:is_system() then
                table.insert(configs, "--with-sdl-prefix=" .. libsdl:installdir())
            end
            import("package.tools.autoconf").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("Mix_Init", {includes = "SDL2/SDL_mixer.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
    end)
