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
             "https://github.com/libsdl-org/SDL_image/releases/download/release-$(version)/SDL2_image-$(version).zip", { alias = "archive" })
    add_urls("https://github.com/libsdl-org/SDL_image.git", { alias = "github" })
    add_versions("archive:2.6.0", "2252cdfd5be73cefaf727edc39c2ef3b7682e797acbd3126df117e925d46aaf6")
    add_versions("archive:2.6.1", "cbfea63a46715c63a1db9e41617e550749a95ffd33ef9bd5ba6e58b2bdca6ed3")
    add_versions("archive:2.6.2", "efe3c229853d0d40c35e5a34c3f532d5d9728f0abc623bc62c962bcef8754205")
    -- todo: add archive versions with their sha256
    add_versions("github:2.0.0",  "release-2.0.0")
    add_versions("github:2.0.1",  "release-2.0.1")
    add_versions("github:2.0.2",  "release-2.0.2")
    add_versions("github:2.0.3",  "release-2.0.3")
    add_versions("github:2.0.4",  "release-2.0.4")
    add_versions("github:2.0.5",  "release-2.0.5")
    add_versions("github:2.6.0",  "release-2.6.0")
    add_versions("github:2.6.1",  "release-2.6.1")
    add_versions("github:2.6.2",  "release-2.6.2")
    add_versions("github:2.6.3",  "release-2.6.3")
    add_versions("github:2.8.0",  "release-2.8.0")
    add_versions("github:2.8.1",  "release-2.8.1")
    add_versions("github:2.8.2",  "release-2.8.2")

    if is_plat("macosx", "iphoneos") then
        add_frameworks("CoreFoundation", "CoreGraphics", "ImageIO", "CoreServices")
    elseif is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    add_includedirs("include", "include/SDL2")

    on_load(function (package)
        if package:config("shared") then
            package:add("deps", "libsdl", { configs = { shared = true }})
        else
            package:add("deps", "libsdl")
        end
    end)

    on_install(function (package)
        local configs = {"-DSDL2IMAGE_SAMPLES=OFF", "-DSDL2IMAGE_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:version():le("2.6.2") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        else
            table.insert(configs, "-DPNG_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        end
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
