package("libsdl_ttf")
    set_homepage("https://www.libsdl.org/projects/SDL_ttf/")
    set_description("Simple DirectMedia Layer text rendering library")
    set_license("zlib")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::SDL2_ttf")
    elseif is_plat("linux") then
        add_extsources("pacman::sdl2_ttf", "apt::libsdl2-ttf-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl2_ttf")
    end

    add_urls("https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-$(version).zip",
             "https://github.com/libsdl-org/SDL_ttf/releases/download/release-$(version)/SDL2_ttf-$(version).zip")
    add_versions("2.20.0", "04e94fc5ecac3475ab35c1d5cf52650df691867e7e4befcc861bf982a747111a")
    add_versions("2.20.1", "18d81ab399c8e39adababe8918691830ba6e0d6448e5baa141ee0ddf87ede2dc")

    add_deps("cmake", "libsdl", "freetype")

    add_includedirs("include", "include/SDL2")

    on_install(function (package)
        local configs = {"-DSDL2TTF_SAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if libsdl and not libsdl:is_system() then
            table.insert(configs, "-DSDL2_DIR=" .. libsdl:installdir())
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("TTF_Init", {includes = "SDL2/SDL_ttf.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
    end)
