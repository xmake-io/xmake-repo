package("libsdl_mixer")
    set_homepage("https://www.libsdl.org/projects/SDL_mixer/")
    set_description("Simple DirectMedia Layer mixer audio library")
    set_license("zlib")

    add_urls("https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-$(version).zip",
             "https://github.com/libsdl-org/SDL_mixer/releases/download/release-$(version)/SDL2_mixer-$(version).zip")
    add_versions("2.0.4", "9affb8c7bf6fbffda0f6906bfb99c0ea50dca9b188ba9e15be90042dc03c5ded")
    add_versions("2.6.0", "aca0ffc96a4bf2a56a16536a269de28e341ce38a46a25180bc1ef75e19b08a3a")
    add_versions("2.6.1", "788c748c1d3a87126511e60995b03526ed4e31e2ba053dffd9dcc8abde97b950")
    add_versions("2.6.2", "61549615a67e731805ca1df553e005be966a625c1d20fb085bf99edeef6e0469")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::SDL2_mixer")
    elseif is_plat("linux") then
        add_extsources("pacman::sdl2_mixer", "apt::libsdl2-mixer-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl2_mixer")
    end

    add_deps("cmake")

    add_includedirs("include", "include/SDL2")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_load(function (package)
        if package:config("shared") then
            package:add("deps", "libsdl", { configs = { shared = true }})
        else
            package:add("deps", "libsdl")
        end
    end)

    on_install(function (package)
        local configs = {"-DSDL2MIXER_SAMPLES=OFF",
                         "-DSDL2MIXER_FLAC=OFF",
                         "-DSDL2MIXER_OPUS=OFF",
                         "-DSDL2MIXER_MOD=OFF",
                         "-DSDL2MIXER_MIDI=OFF",
                         "-DSDL2MIXER_CMD=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        local libsdl = package:dep("libsdl")
        if libsdl and not libsdl:is_system() then
            table.insert(configs, "-DSDL2_DIR=" .. libsdl:installdir())
            local fetchinfo = libsdl:fetch()
            if fetchinfo then
                for _, dir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    if os.isfile(path.join(dir, "SDL_version.h")) then
                        table.insert(configs, "-DSDL2_INCLUDE_DIR=" .. dir)
                        break                        
                    end
                end
                for _, libfile in ipairs(fetchinfo.libfiles) do
                    if libfile:match("SDL2%..+$") or libfile:match("SDL2-static%..+$") then
                        table.insert(configs, "-DSDL2_LIBRARY=" .. table.concat(fetchinfo.libfiles, ";"))
                    end
                end
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("Mix_Init", {includes = "SDL2/SDL_mixer.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
    end)
