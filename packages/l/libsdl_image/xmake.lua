package("libsdl_image")
    set_homepage("http://www.libsdl.org/projects/SDL_image/")
    set_description("Simple DirectMedia Layer image loading library")
    set_license("zlib")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::SDL2_image")
    elseif is_plat("linux") then
        add_extsources("pacman::sdl2_image", "apt::libsdl2-image-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::sdl2_image")
    end

    add_urls("https://www.libsdl.org/projects/SDL_image/release/SDL2_image-$(version).zip",
             "https://github.com/libsdl-org/SDL_image/releases/download/release-$(version)/SDL2_image-$(version).zip")
    add_versions("2.8.4", "a99a906b23d13707df63bc02b7b6a2911282ff82f0f0bd72eaad7a6e53bd1f63")
    add_versions("2.8.3", "3d24c5a2b29813d515d4e37a9703bc3ae849963d1dc09e1ad6b46e1b4a6bb3c1")
    add_versions("2.6.0", "2252cdfd5be73cefaf727edc39c2ef3b7682e797acbd3126df117e925d46aaf6")
    add_versions("2.6.1", "cbfea63a46715c63a1db9e41617e550749a95ffd33ef9bd5ba6e58b2bdca6ed3")
    add_versions("2.6.2", "efe3c229853d0d40c35e5a34c3f532d5d9728f0abc623bc62c962bcef8754205")
    add_versions("2.6.3", "b448a8ca5b7927d9bd1577d393f4d6c59581f87ee525652a27e699941db37b7c")
    add_versions("2.8.0", "fed33c3fe9f8d38ab4460bdd100c4495be40f8afdac1d44bfcd2b0259b74a123")
    add_versions("2.8.1", "0c5afef0ac4bc951a46c6790e576c9b3e7ed2c5ab1d2bbfa5e7e9300718f67d2")
    add_versions("2.8.2", "2196ad6665b68fc453a659e172d67fbf18d548277aa07344dfd2deed9d9b84bd")

    if is_plat("macosx", "iphoneos") then
        add_frameworks("CoreFoundation", "CoreGraphics", "ImageIO", "CoreServices")
    elseif is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    add_includedirs("include", "include/SDL2")

    on_load(function (package)
        package:add("deps", "libsdl", { configs = { shared = package:config("shared") }})
    end)

    on_install(function (package)
        if package:is_plat("wasm") then
            io.replace("CMakeLists.txt", "sdl_find_sdl2(${sdl2_target_name} ${SDL_REQUIRED_VERSION})", "", {plain = true})
            io.replace("CMakeLists.txt", "target_link_libraries(SDL2_image PRIVATE $<BUILD_INTERFACE:${sdl2_target_name}>)", [[
target_include_directories(SDL2_image PRIVATE ${SDL2_INCLUDE_DIR})
target_link_libraries(SDL2_image PRIVATE $<BUILD_INTERFACE:${SDL2_LIBRARY}>)
            ]], {plain = true})
            io.replace("CMakeLists.txt", "target_link_libraries(SDL2_image PRIVATE ${sdl2_target_name})", [[
target_include_directories(SDL2_image PRIVATE ${SDL2_INCLUDE_DIR})
target_link_libraries(SDL2_image PRIVATE ${SDL2_LIBRARY})
            ]], {plain = true})
        end

        local configs = {"-DSDL2IMAGE_SAMPLES=OFF", "-DSDL2IMAGE_TESTS=OFF"}
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
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <SDL2/SDL.h>
            #include <SDL2/SDL_image.h>
            int main(int argc, char** argv) {
                IMG_Init(IMG_INIT_PNG);
                IMG_Quit();
                return 0;
            }
        ]]}, {configs = {defines = "SDL_MAIN_HANDLED"}}));
    end)
