package("libsdl3_mixer")

    set_homepage("https://github.com/libsdl-org/SDL_mixer")
    set_description("An audio mixer that supports various file formats for Simple Directmedia Layer.")
    set_license("zlib")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::sdl3-mixer")
    elseif is_plat("linux") then
        add_extsources("pacman::sdl3_mixer", "apt::libsdl3-mixer-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl3_mixer")
    end

    add_urls("https://www.libsdl.org/projects/SDL_mixer/release/SDL3_mixer-$(version).zip",
             "https://github.com/libsdl-org/SDL_mixer/releases/download/release-$(version)/SDL3_mixer-$(version).zip", { alias = "archive" })
    add_urls("https://github.com/libsdl-org/SDL_mixer.git", {alias = "github", submodules = false})

    add_versions("archive:3.2.4", "bbf0173861d5ee66555605435d4f423261d228649cb03dcb6cf3d24063683625")

    add_versions("github:3.2.4", "release-3.2.4")

    add_deps("cmake")

    on_load(function (package)
        package:add("deps", "libsdl3", { configs = { shared = package:config("shared") }})
    end)

    on_install(function (package)
        local configs = {"-DSDLMIXER_TESTS=OFF", "-DSDLMIXER_EXAMPLES=OFF", "-DSDLMIXER_VENDORED=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("MIX_Version", {includes = "SDL3_mixer/SDL_mixer.h"}))
    end)