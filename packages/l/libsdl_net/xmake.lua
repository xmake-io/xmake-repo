package("libsdl_net")
    set_homepage("https://www.libsdl.org/projects/SDL_net/")
    set_description("Simple DirectMedia Layer networking library")
    set_license("zlib")

    add_urls("https://www.libsdl.org/projects/SDL_net/release/SDL2_net-$(version).zip",
             "https://github.com/libsdl-org/SDL_net/releases/download/release-$(version)/SDL2_net-$(version).zip")
    add_versions("2.2.0", "1eec3a9d43df019d7916a6ecce32f2a3ad5248c82c9c237948afc712399be36d")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::SDL2_net")
    elseif is_plat("linux") then
        add_extsources("pacman::sdl2_net", "apt::libsdl2-net-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl2_net")
    end

    add_deps("cmake", "libsdl")

    if is_plat("windows", "mingw") then
        add_syslinks("Iphlpapi", "ws2_32")
    end

    add_includedirs("include", "include/SDL2")

    on_install(function (package)
        local configs = {"-DSDL2NET_SAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if libsdl and not libsdl:is_system() then
            table.insert(configs, "-DSDL2_DIR=" .. libsdl:installdir())
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SDLNet_Init", {includes = "SDL2/SDL_net.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
    end)
