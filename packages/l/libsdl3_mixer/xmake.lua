package("libsdl3_mixer")
    set_homepage("https://github.com/libsdl-org/SDL_mixer")
    set_description("An audio mixer library for SDL3")
    set_license("Zlib")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::sdl3-mixer")
    elseif is_plat("linux") then
        add_extsources("apt::libsdl3-mixer-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl3_mixer")
    end

    add_urls("https://www.libsdl.org/projects/SDL_mixer/release/SDL3_mixer-$(version).zip",
        "https://github.com/libsdl-org/SDL_mixer/releases/download/release-$(version)/SDL3_mixer-$(version).zip",{ alias = "archive" })
    add_urls("https://github.com/libsdl-org/SDL_mixer.git", {alias = "github", submodules = false})
    
  
    add_versions("3.2.2", "09bb145c399231390b37024aeeeba82c0a105471184a231a5ce3993747ca9308")
    add_versions("3.2.4", "bbf0173861d5ee66555605435d4f423261d228649cb03dcb6cf3d24063683625")

    add_versions("github:3.2.2", "release-3.2.2")
    add_versions("github:3.2.4", "release-3.2.4")
    

    if is_plat("macosx", "iphoneos") then
        add_frameworks("CoreFoundation", "AudioToolbox", "CoreAudio")
    end

    add_deps("cmake")
    add_deps("libsdl3")

    on_install(function (package)
        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"),
            "-DCMAKE_INSTALL_PREFIX=" .. package:installdir(),
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
   
            "-DSDL3MIXER_DEPS_SHARED=ON",  
            "-DSDL3MIXER_VENDORED=OFF",    
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("MIX_Init", {includes = "SDL3_mixer/SDL_mixer.h"}))
    end)