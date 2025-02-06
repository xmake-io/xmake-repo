package("libsdl2_net")
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

    add_deps("cmake")

    if is_plat("windows", "mingw") then
        add_syslinks("iphlpapi", "ws2_32")
    end

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_includedirs("include", "include/SDL2")

    on_load(function (package)
        package:add("deps", "libsdl2", { configs = { shared = package:config("shared") }})
    end)

    on_install(function (package)
        if package:is_plat("wasm") then
            io.replace("CMakeLists.txt", "sdl_find_sdl2(${sdl2_target_name} ${SDL_REQUIRED_VERSION})", "", {plain = true})
            io.replace("CMakeLists.txt", "target_link_libraries(SDL2_net PRIVATE $<BUILD_INTERFACE:${sdl2_target_name}>)", [[
target_include_directories(SDL2_net PRIVATE ${SDL2_INCLUDE_DIR})
target_link_libraries(SDL2_net PRIVATE $<BUILD_INTERFACE:${SDL2_LIBRARY}>)
            ]], {plain = true})
            io.replace("CMakeLists.txt", "target_link_libraries(SDL2_net PRIVATE ${sdl2_target_name})", [[
target_include_directories(SDL2_net PRIVATE ${SDL2_INCLUDE_DIR})
target_link_libraries(SDL2_net PRIVATE ${SDL2_LIBRARY})
            ]], {plain = true})
        end

        local configs = {"-DSDL2NET_SAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        local libsdl2 = package:dep("libsdl2")
        if libsdl2 and not libsdl2:is_system() then
            table.insert(configs, "-DSDL2_DIR=" .. libsdl2:installdir())
            local fetchinfo = libsdl2:fetch()
            if fetchinfo then
                for _, dir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    if os.isfile(path.join(dir, "SDL_version.h")) then
                        table.insert(configs, "-DSDL2_INCLUDE_DIR=" .. dir)
                        break
                    end
                end
                local libfiles = {}
                for _, libfile in ipairs(fetchinfo.libfiles) do
                    if libfile:match("SDL2%..+$") or libfile:match("SDL2-static%..+$") then
                        if not (package:config("shared") and libfile:endswith(".dll")) then
                            table.insert(libfiles, libfile)
                        end
                    end
                end
                table.insert(configs, "-DSDL2_LIBRARY=" .. table.concat(libfiles, ";"))
            end
        end
        io.replace("CMakeLists.txt", "find_package(SDL2test)", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <SDL2/SDL.h>
            #include <SDL2/SDL_net.h>
            int main(int argc, char** argv) {
                SDLNet_Init();
                SDLNet_Quit();
                return 0;
            }
        ]]}, {configs = {defines = "SDL_MAIN_HANDLED"}}));
    end)
