package("libsdl3_ttf")
    set_homepage("https://github.com/libsdl-org/SDL_ttf/")
    set_description("Simple DirectMedia Layer text rendering library")
    set_license("zlib")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::sdl3-ttf")
    elseif is_plat("linux") then
        add_extsources("pacman::sdl3_ttf", "apt::libsdl3-ttf-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl2_ttf")
    end

    add_urls("https://www.libsdl.org/projects/SDL_ttf/release/SDL3_ttf-$(version).zip",
             "https://github.com/libsdl-org/SDL_ttf/releases/download/release-$(version)/SDL3_ttf-$(version).zip", { alias = "archive" })
    add_urls("https://github.com/libsdl-org/SDL_ttf", { alias = "github" })

    add_versions("archive:3.2.0", "ea75fa02ab328cccdff8bf36d2ec891e445e94fa301cd0ef34c662e24d30b704")

    add_versions("github:3.2.0", "release-3.2.0")

    add_deps("cmake", "freetype")

    add_configs("harfbuzz", {description = "Use harfbuzz to improve text shaping", default = true, type = "boolean"})
    add_configs("plutosvg", {description = "Use plutosvg for color emoji support", default = true, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_load(function (package)
        package:add("deps", "libsdl3", { configs = { shared = package:config("shared") }})
        if package:config("harfbuzz") then
          package:add("deps", "harfbuzz") then
        end
        if package:config("plutosvg") then
          package:add("deps", "plutosvg") then
        end
    end)

    on_install(function (package)
        local configs = {"-DSDLTTF_SAMPLES=OFF", "-DSDLTTF_VENDORED=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSDLTTF_HARFBUZZ=" .. (package:config("harfbuzz") and "ON" or "OFF"))
        table.insert(configs, "-DSDLTTF_PLUTOSVG=" .. (package:config("plutosvg") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("TTF_Init", {includes = "SDL3_ttf/SDL_ttf.h"}))
    end)
